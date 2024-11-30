{
  pkgs,
  lib,
  config,
  ...
}:
lib.utilMods.mkDesktopModule config "waydroid" {
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [nur.repos.ataraxiasjel.waydroid-script];
}
