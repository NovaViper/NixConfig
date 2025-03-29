{
  config,
  lib,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    firewall.enable = true;
  };

  users.users.${config.userVars.username}.extraGroups = ["networkmanager"];

  systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Make NetworkManager use iwd
  networking.networkmanager.wifi.backend = "iwd";

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
