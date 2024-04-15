{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # for a WiFi printer
    openFirewall = true;
    # Make user systemd service work with avahi
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
