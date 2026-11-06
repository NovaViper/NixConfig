{ lib, ... }:
{
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.avahi.enable = lib.mkForce false;
  services.resolved.enable = true;

  networking = {
    # NixOS's default Ethernet DHCP rule obtains OCI's private address and
    # gateway without depending on eth0 versus enp0s6 naming.
    useNetworkd = true;
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    firewall.rejectPackets = true;
    timeServers = [ "169.254.169.254" ];
  };
}
