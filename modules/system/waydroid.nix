{
  pkgs,
  lib,
  config,
  ...
}:
lib.utilMods.mkModule config "waydroid" {
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [nur.repos.ataraxiasjel.waydroid-script];
}
