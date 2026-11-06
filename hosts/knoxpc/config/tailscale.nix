{
  config,
  lib,
  myLib,
  ...
}:
{
  sops.secrets."tailscale-authkey" = myLib.secrets.mkSecretFile {
    source = "secrets.yaml";
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
  };

  # Check these ports before Tailscale can accept them: allow Caddy (80/443)
  # from the IPv4 LAN over Wi-Fi and keep Homepage (8082) localhost-only.
  networking.firewall = {
    extraCommands = ''
      iptables -N homepage-lan
      iptables -A homepage-lan -i lo -j RETURN
      iptables -A homepage-lan -i wlp4s0 -s 192.168.1.0/24 -p tcp -m multiport --dports 80,443 -j RETURN
      iptables -A homepage-lan -j DROP
      iptables -I INPUT 1 -p tcp -m multiport --dports 80,443,8082 -j homepage-lan
      ip6tables -N homepage-lan
      ip6tables -A homepage-lan -i lo -j RETURN
      ip6tables -A homepage-lan -j DROP
      ip6tables -I INPUT 1 -p tcp -m multiport --dports 80,443,8082 -j homepage-lan
    '';
    extraStopCommands = ''
      for firewall in iptables ip6tables; do
        $firewall -D INPUT -p tcp -m multiport --dports 80,443,8082 -j homepage-lan 2>/dev/null || true
        # Remove the previous HTTP-only rule when upgrading the firewall.
        $firewall -D INPUT -p tcp -m multiport --dports 80,8082 -j homepage-lan 2>/dev/null || true
        $firewall -F homepage-lan 2>/dev/null || true
        $firewall -X homepage-lan 2>/dev/null || true
      done
    '';
  };

  services.tailscale = {
    openFirewall = true;
    authKeyFile = config.sops.secrets."tailscale-authkey".path;
    extraUpFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.1.0/24"
    ];
    useRoutingFeatures = lib.mkForce "server";
  };
}
