{ config, lib, pkgs, ... }: {
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
