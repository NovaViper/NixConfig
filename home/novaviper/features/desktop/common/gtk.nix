{ config, lib, pkgs, ... }:
let
  notKDE = if (config.variables.desktop.environment != null
    && config.variables.desktop.environment != "kde") then
    true
  else
    false;
in {
  gtk.enable = notKDE;

  services.xsettingsd.enable = notKDE;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
