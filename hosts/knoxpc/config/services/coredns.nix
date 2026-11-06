{
  config,
  lib,
  pkgs,
  ...
}:
let
  dns = config.localdns;
in
{
  # Use the hostname as the authoritative server name for the local DNS domain and zone records
  localdns.extraNames = lib.singleton config.networking.hostName;

  services.coredns = {
    enable = true;
    config = ''
      ${dns.domain}:53 {
        # Force the ACL to allow only the LAN and loopback addresses, and block all others.
        bind ${dns.address} 127.0.0.1
        acl {
          allow net 192.168.1.0/24 127.0.0.0/8
          block
        }
        errors
        cache 300
        # Create an authoritative zone for home.arpa with the following records.
        file ${pkgs.writeText "${dns.domain}.zone" ''
          $ORIGIN ${dns.domain}.
          $TTL 300
          @ IN SOA ${config.networking.hostName}.${dns.domain}. hostmaster.${dns.domain}. (
            2026102501  ; Serial
            3600        ; Refresh
            600         ; Retry
            86400       ; Expire
            300         ; Minimum
          )
          @ IN NS ${config.networking.hostName}.${dns.domain}.
          ${dns.zoneRecords}
        ''} ${dns.domain}
      }
    '';
  };

  networking.firewall.interfaces.wlp4s0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  systemd.services.coredns = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # Disable the default systemd service start limit; allowing the service to retry indefinitely until the address is available
    startLimitIntervalSec = 0;

    # Additional hardening options; based on recommendations from the systemd.exec man page
    # The upstream module already uses DynamicUser, NoNewPrivileges, and
    # limits capabilities to binding privileged ports.
    serviceConfig = {
      RestartSec = "15s";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_UNIX"
      ];
      IPAddressDeny = [ "any" ]; # Deny IP traffic unless allowed below.
      IPAddressAllow = [
        "127.0.0.0/8" # IPv4 loopback.
        "192.168.1.0/24" # Local LAN.
      ];
    };
  };
}
