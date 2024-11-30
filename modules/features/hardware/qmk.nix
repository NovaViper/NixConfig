{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkDesktopModule config "qmk" {
  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = with pkgs; [via qmk];
}
