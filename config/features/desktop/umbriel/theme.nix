{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  hm-config = config.hm;
in
{
  # Theming for QT and GTK applications.
  # kosslan's QtEngine helps massively!
  imports = [ inputs.qtengine.nixosModules.default ];
  qt.enable = true;
  qt.platformTheme = null;
  environment.variables.QT_QPA_PLATFORMTHEME = lib.mkForce "qtengine";

  environment.systemPackages = with pkgs; [
    kdePackages.breeze
    kdePackages.breeze.qt5 # Needed if you want Qt5 support.
    kdePackages.breeze-icons
    papirus-icon-theme
  ];
  programs.qtengine = {
    enable = true;

    config = {
      theme = {
        colorScheme = "${hm-config.xdg.dataHome}/color-schemes/noctalia.colors";
        iconTheme = "Papirus-Dark";
        style = "breeze";

        # font = {
        #   family = "<font name>";
        #   size = 11;
        #   weight = -1;
        # };
        #
        # fontFixed = {
        #   family = "<font name>";
        #   size = 11;
        #   weight = -1;
        # };
      };

      misc = {
        singleClickActivate = false;
        menusHaveIcons = true;
        shortcutsForContextMenus = true;
      };
    };
  };

  # Keep GTK apps visually consistent with the Noctalia greeter
  # (matching Bibata cursor at minimum, adw-gtk3 for theme coherence)
  hm.gtk.enable = true;
  hm.gtk.cursorTheme = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
  };
  hm.gtk.theme = {
    package = pkgs.adw-gtk3;
    name = "adw-gtk3-dark";
  };
  hm.gtk.iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = "Papirus-Dark";
  };

  hm.dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
    icon-theme = "Papirus-Dark";
    cursor-theme = "Bibata-Modern-Ice";
    cursor-size = 24;
  };

}
