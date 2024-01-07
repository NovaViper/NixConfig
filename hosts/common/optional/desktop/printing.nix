{ config, lib, pkgs, ... }:

{
  # Printer Setup
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplipWithPlugin ];
  };

  # Scanner Setup
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan hplipWithPlugin ];
  };

  # Install installation
  environment.systemPackages = with pkgs; [ hplipWithPlugin ];
}
