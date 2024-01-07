{ config, lib, pkgs, ... }:

{

  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${config.theme.name}";
      "Net/IconThemeName" = "${config.theme.iconTheme.name}";
    };
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
