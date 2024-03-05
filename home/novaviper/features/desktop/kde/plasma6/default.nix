{ config, lib, pkgs, ... }:
with lib;

{
  imports = [ ../common.nix ];

  xdg.portal = {
    extraPortals = with pkgs.kdePackages; [ xdg-desktop-portal-kde ];
    configPackages = with pkgs.kdePackages;
      mkDefault [ xdg-desktop-portal-kde ];
  };
}
