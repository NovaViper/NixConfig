{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "openrgb" {
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.package = pkgs.openrgb-with-all-plugins;
}
