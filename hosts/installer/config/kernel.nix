{
  lib,
  pkgs,
  ...
}:
{
  # Ensure we use the LTS kernel
  boot.kernelPackages = pkgs.linuxPackages;

  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "ext2"
    "ext3"
    "ext4"
    "exfat"
    "f2fs"
    "fat8"
    "fat16"
    "fat32"
    "ntfs"
    "xfs"
    "zfs"
  ];
}
