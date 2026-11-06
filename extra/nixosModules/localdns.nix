{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    mkMerge
    ;
  cfg = config.localdns;
  names = lib.unique (lib.attrNames cfg.proxies ++ cfg.extraNames);
in
{
  options.localdns = {
    domain = mkOption {
      type = types.str;
      default = "home.arpa";
      description = "Domain used for local DNS records. Defaults to the RFC 8375 reserved domain (home.arpa).";
    };

    address = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "192.168.1.120";
      description = "Shared IPv4 address for the local hostnames. Make sure to bind this address to DHCP on the system OR on a OpenWRT router.";
    };

    extraNames = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "knoxpc"
        "syncthing"
      ];
      description = "Additional DNS-only hostnames pointing to the shared address. Proxy hostnames are included automatically.";
    };

    proxies = mkOption {
      type = types.attrsOf types.port;
      default = { };
      example.homepage = 8082;
      description = "Local hostnames mapped to loopback HTTP backend ports. Also adds their DNS names.";
    };

    virtualHosts = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      internal = true;
      description = "Generated Caddy virtual hosts using internal TLS and the lan_only snippet.";
    };

    zoneRecords = mkOption {
      type = types.lines;
      readOnly = true;
      internal = true;
      description = "Generated A records for inclusion in a CoreDNS zone.";
    };
  };

  config = {
    assertions = [
      {
        assertion = names == [ ] || cfg.address != null;
        message = "localdns.address must be set when proxies or extraNames are configured.";
      }
    ];

    # Generate virtual hosts for each proxy and generate A records for each name
    localdns.virtualHosts = lib.mapAttrs' (
      name: port:
      lib.nameValuePair "https://${name}.${cfg.domain}" {
        listenAddresses = lib.optional (cfg.address != null) cfg.address;
        extraConfig = ''
          tls internal
          import lan_only
          reverse_proxy 127.0.0.1:${toString port} {
            header_up X-Real-IP {remote_host}
          }
        '';
      }
    ) cfg.proxies;

    # Generate A records for each name pointing to the shared address, if set
    localdns.zoneRecords =
      if cfg.address == null then
        ""
      else
        lib.concatMapStringsSep "\n" (name: "${name} IN A ${cfg.address}") names;
  };
}
