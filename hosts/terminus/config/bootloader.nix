{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Pin to the latest kernel packages to avoid issues with the Oracle Cloud hypervisor
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.systemd-boot = {
    memtest86.enable = lib.mkForce false;
    configurationLimit = lib.mkForce 5;
  };

  # Creates more predictable interface names
  # Based on https://wiki.nixos.org/wiki/Install_NixOS_on_Oracle_Cloud#NixOS_configuration.nix
  boot.kernelParams = [ "net.ifnames=0" ];
}
