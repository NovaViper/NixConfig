{ config, lib, pkgs, ... }:

{
  services = {
    # Printer Setup
    printing = {
      enable = true;
      drivers = with pkgs; [ hplipWithPlugin ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      # for a WiFi printer
      openFirewall = true;
    };
  };

  # Scanner Setup
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan hplipWithPlugin ];
  };

  # Install installation
  environment.systemPackages = with pkgs; [ hplipWithPlugin ];
}
