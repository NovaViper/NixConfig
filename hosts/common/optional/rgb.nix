{ config, lib, pkgs, ... }:

{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = lib.mkDefault config.variables.machine.motherboard;
  };
}
