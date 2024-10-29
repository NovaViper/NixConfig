{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "openrgb" {
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };
}
