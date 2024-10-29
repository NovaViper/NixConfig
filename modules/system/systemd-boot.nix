{
  config,
  lib,
  ...
}:
lib.utilMods.mkModule config "systemd-boot" {
  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
