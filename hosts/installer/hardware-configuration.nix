{ lib, pkgs, ... }: {
  # Use the default LTS kernel; the shared 7.3 kernel is unsupported by ZFS.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
}
