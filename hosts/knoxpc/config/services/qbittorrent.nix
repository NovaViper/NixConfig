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
  # Paths we need
  downloads = "/storage/media/Downloads";

  # Service dependencies
  torrentDependencies = [
    "wireguard-proton0.service"
  ];
  # Defaults for the secrets needed for qBittorrent
  secretDefaults = {
    source = "secrets.yaml";
    subDir = [
      "hosts"
      config.networking.hostName
    ];
  };
  qbittorrentOwnership = {
    owner = cfg.user;
    group = cfg.group;
  };

  scanCompletedTorrent = pkgs.writeShellScript "qbittorrent-clamav-scan" ''
    set -euo pipefail
    # Pass the content path as one argument; never evaluate torrent names as shell code
    /etc/clamav/scan torrent "$1" 2>&1 \
      | ${pkgs.systemd}/bin/systemd-cat --identifier=qbittorrent-clamav
  '';

  # Replace locally with the DNS IP from Proton's WireGuard configuration
  vpnResolvConf = pkgs.writeText "qbittorrent-resolv.conf" ''
    nameserver 10.2.0.1
    nameserver 2a07:b944::2:1
  '';

  # Allow only loopback and VPN egress, for both IPv4 and IPv6
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
  localdns.proxies.qbittorrent = cfg.webuiPort;

  # Secrets setup
  sops.secrets = {
    vpn-key = myLib.secrets.mkSecretFile secretDefaults;
    qBtpass-hash = myLib.secrets.mkSecretFile (secretDefaults // qbittorrentOwnership);
  };
  sops.templates.qbittorrent-password-config = qbittorrentOwnership // {
    content = ''
      Password_PBKDF2=${config.sops.placeholder.qBtpass-hash}
    '';
    restartUnits = [ "qbittorrent.service" ];
  };

  # qBittorrent application and storage
  services.qbittorrent = {
    enable = true;
    profileDir = "/storage/services/qbittorrent";
    webuiPort = 8080;
    openFirewall = false;
    serverConfig = {
      AutoRun = {
        enabled = true;
        program = ''${scanCompletedTorrent} "%F"'';
      };
      LegalNotice.Accepted = true;
      BitTorrent.Session = {
        DefaultSavePath = downloads;
        Interface = "proton0";
        # Stop at a 1:1 upload ratio or 24 hours of seeding, whichever comes first
        # And also keep the torrent and its files available for the media stack!
        GlobalMaxRatio = 1.0;
        GlobalMaxSeedingMinutes = 1440;
        ShareLimitAction = "Stop";
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
    # Make sure the group is set to media so that Sonarr can read/write files
    "d ${downloads} 2770 ${cfg.user} media - -"
  ];

  # ProtonVPN tunnel setup
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

  # Setup the network namespace and firewall before bringing up the WireGuard
  # interface to ensure only qBittorrent can use the VPN and that it cannot
  # leak traffic if the VPN is down
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
      ip netns exec qbittorrent nft -f ${vpnFirewall}
      ip -n qbittorrent link set lo up
    '';
    postStop = ''
      ip netns del qbittorrent 2>/dev/null || true
    '';
  };

  # Reorder the services; namespace/firewall -> WireGuard -> qBittorrent
  systemd.services.wireguard-proton0 = {
    requires = [ "qbittorrent-netns.service" ];
    after = [ "qbittorrent-netns.service" ];
    bindsTo = [ "qbittorrent-netns.service" ];
  };

  # Keep namespace diagnostics and qBittorrent on the same VPN DNS server
  environment.etc."netns/qbittorrent/resolv.conf".source = vpnResolvConf;
  systemd.services.qbittorrent = {
    requires = torrentDependencies ++ [ "clamav-daemon.socket" ];
    after = torrentDependencies ++ [ "clamav-daemon.socket" ];
    bindsTo = [ "wireguard-proton0.service" ];
    partOf = [ "wireguard-proton0.service" ];
    serviceConfig = {
      # Ensure new downloads are created with the correct ownership and group
      UMask = "0007";
      # Place the rendered password into the qBittorrent config file before starting the service
      ExecStartPre = lib.mkAfter [
        (pkgs.writeShellScript "qbittorrent-password" ''
          set -eu
          test -r ${config.sops.templates.qbittorrent-password-config.path}
          ${pkgs.gnused}/bin/sed -i '/^\[WebUI\]$/r ${config.sops.templates.qbittorrent-password-config.path}' ${lib.escapeShellArg "${cfg.profileDir}/qBittorrent/config/qBittorrent.conf"}
        '')
      ];
      NetworkNamespacePath = "/run/netns/qbittorrent";
      BindReadOnlyPaths = [ "${vpnResolvConf}:/etc/resolv.conf" ];
      # The application cannot change firewall rules, interfaces or namespaces
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      RestrictNamespaces = true;
      # Completion scans and journal logging use local Unix sockets inside the VPN namespace.
      RestrictAddressFamilies = [ "AF_UNIX" ];
    };
  };

  # Caddy will connect to this socket and then qBittorrent will see the connection as
  # coming from the VPN interface, without any other traffic being able to leak out
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
