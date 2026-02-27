{
  lib,
  pkgs,
  ...
}:
{
  # Ensure we use the LTS kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # Forcibly disable zfs for latest Linux firmware
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
