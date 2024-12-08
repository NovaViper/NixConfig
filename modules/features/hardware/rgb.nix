{
  config,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkDesktopModule config "openrgb" {
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.package = pkgs.openrgb-with-all-plugins;
}
