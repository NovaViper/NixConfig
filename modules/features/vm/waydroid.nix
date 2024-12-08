{
  pkgs,
  myLib,
  config,
  ...
}:
myLib.utilMods.mkDesktopModule config "waydroid" {
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [nur.repos.ataraxiasjel.waydroid-script];
}
