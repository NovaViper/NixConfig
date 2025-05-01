{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.pkgs.linuxPackages_6_12;
}
