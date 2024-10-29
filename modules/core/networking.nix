_: {
  networking.firewall.enable = true;
  systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # for a WiFi printer
    openFirewall = true;
    # Make user systemd service work with avahi
    publish.enable = true;
    publish.userServices = true;
  };
}
