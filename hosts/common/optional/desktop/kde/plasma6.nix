{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa ];
}
