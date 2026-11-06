{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.qbittorrent;
  downloads = "/storage/media/Downloads";

  # Replace locally with the DNS IP from Proton's WireGuard configuration.
  vpnResolvConf = pkgs.writeText "qbittorrent-resolv.conf" ''
    nameserver 10.2.0.1
    nameserver 2a07:b944::2:1
  '';

  # Allow only loopback and VPN egress, for both IPv4 and IPv6.
  vpnFirewall = pkgs.writeText "qbittorrent-vpn-only.nft" ''
    table inet vpn_only {
      chain output {
        type filter hook output priority filter; policy drop;
        oifname "lo" accept
        oifname "proton0" accept
      }
      chain forward {
        type filter hook forward priority filter; policy drop;
      }
    }
  '';
in
{
  sops.secrets = {
    vpn-key = myLib.secrets.mkSecretFile {
      source = "secrets.yaml";
      subDir = [
        "hosts"
        "${config.networking.hostName}"
      ];
    };
    qBtpass-hash = myLib.secrets.mkSecretFile {
      source = "secrets.yaml";
      owner = "qbittorrent";
      group = "qbittorrent";
      subDir = [
        "hosts"
        "${config.networking.hostName}"
      ];
    };
  };

  sops.templates."qbittorrent-password.conf" = {
    content = ''
      Password_PBKDF2=${config.sops.placeholder.qBtpass-hash}
    '';
    owner = cfg.user;
    group = cfg.group;
    restartUnits = [ "qbittorrent.service" ];
  };

  # qBittorrent application and storage.
  services.qbittorrent = {
    enable = true;
    profileDir = "/storage/services/qbittorrent";
    webuiPort = 8080;
    openFirewall = false;

    serverConfig = {
      LegalNotice.Accepted = true;
      BitTorrent.Session = {
        DefaultSavePath = downloads;
        Interface = "proton0";
      };
      WebUI = {
        Username = "admin";
        ServerDomains = "qbittorrent.${config.localdns.domain}";
        ReverseProxySupportEnabled = true;
        TrustedReverseProxiesList = "127.0.0.1";
        Address = "127.0.0.1";
        LocalHostAuth = true;
        AuthSubnetWhitelistEnabled = false;
      };
    };
  };

  systemd.tmpfiles.rules = lib.mkIf cfg.enable [
    "d ${cfg.profileDir} 0700 ${cfg.user} ${cfg.group} - -"
    # Setgid shares new downloads with Sonarr; existing contents are untouched.
    "d ${downloads} 2770 ${cfg.user} media - -"
  ];

  # ProtonVPN tunnel (credentials stay in the existing secret sources).
  networking.wireguard.interfaces.proton0 = {
    ips = [
      "10.2.0.2/32"
      "2a07:b944::2:2/128"
    ];
    privateKeyFile = config.sops.secrets.vpn-key.path;
    # Only qBittorrent will be allowed to use this interface
    interfaceNamespace = "qbittorrent";
    peers = [
      {
        publicKey = inputs.nix-secrets.networking.vpn.publicKey;
        endpoint = inputs.nix-secrets.networking.vpn.endpointv4;
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        persistentKeepalive = 25;
      }
    ];
  };

  # Network namespace and firewall kill switch.
  # Only loopback and ProtonVPN are available inside this namespace.
  systemd.services.qbittorrent-netns = {
    description = "Isolated network for qBittorrent";
    before = [ "wireguard-proton0.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      pkgs.iproute2
      pkgs.nftables
    ];
    script = ''
      ip netns add qbittorrent
      # Fail closed: install the firewall before bringing up any interfaces.
      ip netns exec qbittorrent nft -f ${vpnFirewall}
      ip -n qbittorrent link set lo up
    '';
    postStop = ''
      ip netns del qbittorrent 2>/dev/null || true
    '';
  };

  # Service ordering: namespace/firewall -> WireGuard -> qBittorrent.
  systemd.services.wireguard-proton0 = {
    requires = [ "qbittorrent-netns.service" ];
    after = [ "qbittorrent-netns.service" ];
    bindsTo = [ "qbittorrent-netns.service" ];
  };

  # Keep namespace diagnostics and qBittorrent on the same VPN DNS server.
  environment.etc."netns/qbittorrent/resolv.conf".source = vpnResolvConf;
  systemd.services.qbittorrent = {
    requires = [ "wireguard-proton0.service" ];
    after = [ "wireguard-proton0.service" ];
    bindsTo = [ "wireguard-proton0.service" ];
    partOf = [ "wireguard-proton0.service" ];
    serviceConfig = {
      # Insert the rendered password after the module installs the other settings.
      # New downloads remain writable by the shared media group.
      UMask = "0007";
      ExecStartPre = lib.mkAfter [
        (pkgs.writeShellScript "qbittorrent-password" ''
          set -eu
          test -r ${config.sops.templates."qbittorrent-password.conf".path}
          ${pkgs.gnused}/bin/sed -i '/^\[WebUI\]$/r ${
            config.sops.templates."qbittorrent-password.conf".path
          }' ${lib.escapeShellArg "${cfg.profileDir}/qBittorrent/config/qBittorrent.conf"}
        '')
      ];
      NetworkNamespacePath = "/run/netns/qbittorrent";
      BindReadOnlyPaths = [ "${vpnResolvConf}:/etc/resolv.conf" ];
      # The application cannot change firewall rules, interfaces or namespaces.
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      RestrictNamespaces = true;
    };
  };

  # LAN HTTPS access through Caddy and the loopback socket bridge.
  localdns.proxies.qbittorrent = cfg.webuiPort;

  # Caddy connects to this host-side loopback socket. The proxy joins the VPN
  # namespace and reaches qBittorrent there, without adding a fallback route.
  systemd.sockets.qbittorrent-web = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "127.0.0.1:${toString cfg.webuiPort}" ];
  };

  systemd.services.qbittorrent-web = {
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];
    bindsTo = [ "wireguard-proton0.service" ];
    partOf = [ "wireguard-proton0.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString cfg.webuiPort}";
      NetworkNamespacePath = "/run/netns/qbittorrent";
      DynamicUser = true;
      NoNewPrivileges = true;
    };
  };
}
