{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      # Limit the number of generations to keep
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };
}
