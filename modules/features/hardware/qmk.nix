{
  config,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkDesktopModule config "qmk" {
  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = with pkgs; [via qmk];
}
