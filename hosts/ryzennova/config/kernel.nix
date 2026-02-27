{ pkgs, ... }:
{
  # Ensure we use the LTS kernel
  boot.kernelPackages = pkgs.linuxPackages;
}
