{
  lib,
  pkgs,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Forcibly disable zfs for latest Linux firmware
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
