{
  config,
  lib,
  ...
}:
{
  services.caddy = {
    enable = true;
    email = config.vars.user.email;
    openFirewall = false;
    globalConfig = ''
      # Use TCP for HTTP/HTTPS
      servers {
        protocols h1 h2
      }
    '';
    # Match the actual peer address, rather than client-supplied headers
    extraConfig = ''
      (lan_only) {
        @outside not remote_ip 192.168.1.0/24 127.0.0.0/8
        respond @outside "Forbidden" 403
      }
    '';

    # Generate the virtual hosts for each internal service, using the LAN-only access policy
    virtualHosts = config.localdns.virtualHosts;
  };

  # Force Caddy to load the configuration AFTER the network is online; Wi-Fi and
  # DHCP should be on before Caddy starts, otherwise it will fail to bind to the ports
  systemd.services.caddy = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # Let systemd wait for the network to be online
    startLimitIntervalSec = lib.mkForce 0;
    serviceConfig = {
      # Make sure the service is restarted on any failure, including bind failures
      RestartPreventExitStatus = lib.mkForce [ ];
    };
  };
  # Setup firewall rules to allow Caddy to bind to the HTTP/HTTPS ports
  networking.firewall.interfaces.wlp4s0.allowedTCPPorts = [
    80
    443
  ];
}
