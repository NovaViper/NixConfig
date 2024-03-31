{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ../common ];

  variables.desktop.environment = "kde";

  xdg = {
    mimeApps = {
      associations = {
        added = {
          "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
        };
      };
      defaultApplications = {
        "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
      };
    };

    configFile = {
      # Yakuake settings
      "yakuakerc" = mkIf config.variables.useKonsole {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/yakuake/yakuakerc";
      };
    };

    dataFile = mkMerge [
      /* ({
           # Dolphin settings
           "kxmlgui5/dolphin/dolphinui.rc".source =
             config.lib.file.mkOutOfStoreSymlink
             "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/dolphin/dolphinui.rc";
         })
      */
      (mkIf config.variables.useKonsole {
        # Konsole settings
        "konsole" = {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/konsole";
          recursive = true;
        };
        # Yakuake settings
        "yakuake/skins/Dracula".source = fetchGit {
          url = "https://github.com/dracula/yakuake";
          rev = "591a705898763167dd5aca2289d170f91a85aa56";
        };
      })
    ];
  };

  programs = {
    /* konsole = {
         enable = mkIf (config.variables.useKonsole) true;
         defaultProfile = "DefaultThemed";
         profiles.DefaultThemed = {
           name = "DefaultThemed";
           #colorScheme = "";
           font = {
             name = "${config.stylix.fonts.monospace.name}";
             size = config.stylix.fonts.sizes.terminal;
           };
         };
       };
    */
    plasma = {
      enable = true;
      workspace.clickItemTo = "select";
      kwin.titlebarButtons = {
        left = [ "on-all-desktops" "keep-above-windows" ];
        right = [ "help" "minimize" "maximize" "close" ];
      };
      shortcuts.yakuake =
        mkIf config.variables.useKonsole { toggle-window-state = "F12"; };
      configFile = {
        kglobalshortcutsrc.yakuake = mkIf config.variables.useKonsole {
          "_k_friendly_name".value = "Yakuake";
        };
        kwinrc.NightColor.Active.value = true;
      };
    };
  };
}
