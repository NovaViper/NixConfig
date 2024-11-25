{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "qmk" {
  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = with pkgs; [via qmk];
}
