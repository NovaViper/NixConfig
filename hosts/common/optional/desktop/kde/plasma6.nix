{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  services.xserver.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa ];
}
