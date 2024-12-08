{
  config,
  myLib,
  ...
}:
myLib.utilMods.mkModule config "systemd-boot" {
  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
