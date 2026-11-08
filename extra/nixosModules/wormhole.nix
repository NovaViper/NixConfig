{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    mkAfter
    mkBefore
    ;
  cfg = config.networking.wormhole;
  isVps = config.networking.hostName == "terminus";

  # Addresses for the two ends of the tunnel
  address = if isVps then "10.9.0.1" else "10.9.0.2";
  peerAddress = if isVps then "10.9.0.2" else "10.9.0.1";
  peerPublicKey = if cfg.peerPublicKey == null then "" else cfg.peerPublicKey;

  interface = "wg-wormhole";
  service = "wireguard-${interface}.service";
  dependencies = [
    "firewall.service"
  ]
  ++ lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
  directions = [
    {
      hook = "INPUT";
      flag = "-i";
      chain = "${interface}-input";
      source = peerAddress;
      destination = address;
    }
    {
      hook = "OUTPUT";
      flag = "-o";
      chain = "${interface}-output";
      source = address;
      destination = peerAddress;
    }
  ];

  # Secrets setup
  secretPermissions = {
    owner = "root";
    mode = "0400";
    restartUnits = [ service ];
  };
  secret = myLib.secrets.mkSecretFile (
    {
      source = "secrets.yaml";
      subDir = "hosts";
    }
    // secretPermissions
  );
in
{
  options.networking.wormhole = {
    enable = mkEnableOption "the Wormhole WireGuard tunnel";
    peerPublicKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Public WireGuard key of the other host.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.elem config.networking.hostName [
          "terminus"
          "knoxpc"
        ];
        message = "wormhole is only supported on terminus and knoxpc.";
      }
      {
        assertion =
          cfg.peerPublicKey != null && builtins.match "[A-Za-z0-9+/]{43}=" cfg.peerPublicKey != null;
        message = "wormhole requires the other host's real WireGuard public key.";
      }
      {
        assertion = config.networking.firewall.enable && !config.networking.nftables.enable;
        message = "wormhole isolation requires the existing iptables firewall backend.";
      }
      {
        assertion = !(builtins.elem "wg-wormhole" config.networking.firewall.trustedInterfaces);
        message = "wg-wormhole must not be a trusted firewall interface.";
      }
      {
        assertion = config.networking.firewall.allowPing;
        message = "wormhole requires allowPing for its restricted peer connectivity checks.";
      }
    ];

    # Start the tunnel only after the firewall and runtime secrets are ready!
    systemd.services.wireguard-wg-wormhole = {
      requires = dependencies;
      after = dependencies;
      bindsTo = [ "firewall.service" ];
    };

    sops.secrets."wireguard/private" = secret // {
      key = "wireguard/${config.networking.hostName}/wormhole";
    };
    sops.secrets."networking/terminus/address" = mkIf (!isVps) secret;
    sops.templates."wormhole-endpoint.conf" = mkIf (!isVps) (
      secretPermissions
      // {
        content = ''
          [Peer]
          PublicKey = ${peerPublicKey}
          Endpoint = ${config.sops.placeholder."networking/terminus/address"}:51820
        '';
      }
    );

    # Use the service backend on both hosts so firewall ordering and runtime
    # endpoint hooks apply even when the host's other links use networkd
    networking.wireguard.useNetworkd = false;

    networking.wireguard.interfaces.wg-wormhole = {
      ips = [ "${address}/32" ];
      privateKeyFile = config.sops.secrets."wireguard/private".path;
      # Load the endpoint from the runtime SOPS template.
      postSetup = lib.optionalString (!isVps) ''
        ${pkgs.wireguard-tools}/bin/wg addconf wg-wormhole ${
          config.sops.templates."wormhole-endpoint.conf".path
        }
      '';
      peers = [
        (
          {
            publicKey = peerPublicKey;
            allowedIPs = [ "${peerAddress}/32" ];
          }
          // lib.optionalAttrs (!isVps) {
            persistentKeepalive = 25;
          }
        )
      ];
    }
    // lib.optionalAttrs isVps { listenPort = 51820; };

    networking.firewall = {
      allowedUDPPorts = lib.optionals isVps [ 51820 ];
      # Enforce isolation before filter-table accepts from other services.. like
      # Tailscale
      extraCommands = mkAfter (
        lib.concatMapStringsSep "\n" (direction: ''
          iptables -t mangle -N ${direction.chain}
          iptables -t mangle -A ${direction.chain} -s ${direction.source} -d ${direction.destination} -p icmp --icmp-type echo-request -m limit --limit 5/second --limit-burst 10 -j RETURN
          iptables -t mangle -A ${direction.chain} -s ${direction.source} -d ${direction.destination} -p icmp --icmp-type echo-reply -m conntrack --ctstate ESTABLISHED -j RETURN
          iptables -t mangle -A ${direction.chain} -j DROP
          iptables -t mangle -I ${direction.hook} 1 ${direction.flag} ${interface} -j ${direction.chain}
        '') directions
        + ''
          ip6tables -t mangle -I INPUT 1 -i wg-wormhole -j DROP
          ip6tables -t mangle -I OUTPUT 1 -o wg-wormhole -j DROP
          for firewall in iptables ip6tables; do
            $firewall -t mangle -I FORWARD 1 -i wg-wormhole -j DROP
            $firewall -t mangle -I FORWARD 1 -o wg-wormhole -j DROP
          done
        ''
      );
      extraStopCommands = mkBefore (
        lib.concatMapStringsSep "\n" (direction: ''
          iptables -t mangle -D ${direction.hook} ${direction.flag} ${interface} -j ${direction.chain} 2>/dev/null || true
          iptables -t mangle -F ${direction.chain} 2>/dev/null || true
          iptables -t mangle -X ${direction.chain} 2>/dev/null || true
        '') directions
        + ''
          ip6tables -t mangle -D INPUT -i wg-wormhole -j DROP 2>/dev/null || true
          ip6tables -t mangle -D OUTPUT -o wg-wormhole -j DROP 2>/dev/null || true
          for firewall in iptables ip6tables; do
            $firewall -t mangle -D FORWARD -i wg-wormhole -j DROP 2>/dev/null || true
            $firewall -t mangle -D FORWARD -o wg-wormhole -j DROP 2>/dev/null || true
          done
        ''
      );
    };
  };
}
