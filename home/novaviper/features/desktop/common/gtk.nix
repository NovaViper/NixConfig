{ config, lib, pkgs, ... }:
let
  notKDE =
    if (config.variables.desktop.environment != "kde") then true else false;
in {
  gtk.enable = notKDE;

  services.xsettingsd = {
    enable = notKDE;
    settings = {
      "Net/ThemeName" = "${config.theme.name}";
      "Net/IconThemeName" = "${config.theme.iconTheme.name}";
      "Gtk/CursorThemeName" = "${config.theme.cursorTheme.name}";
      "Gtk/CursorThemeSize" = config.theme.cursorTheme.size;
    };
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
