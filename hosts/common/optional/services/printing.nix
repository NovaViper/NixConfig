{
  config,
  lib,
  pkgs,
  ...
}: let
  printers = with pkgs; [hplipWithPlugin cnijfilter2];
in {
  # Printer Setup
  services.printing = {
    enable = true;
    drivers = printers;
  };

  # Scanner Setup
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [sane-airscan] ++ printers;
  };

  # Install installation
  environment.systemPackages = printers;
}
