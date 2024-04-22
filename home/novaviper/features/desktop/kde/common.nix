{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  utils = import ../../../../lib/utils.nix {inherit config pkgs;};
in {
  imports = [../common];

  variables.desktop.environment = "kde";

  xdg = {
    mimeApps = {
      associations = {
        added = {
          "x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
        };
      };
      defaultApplications = {
        "x-scheme-handler/tel" = ["org.kde.kdeconnect.handler.desktop"];
      };
    };

    configFile = {
      # Yakuake settings
      "yakuakerc" = mkIf config.variables.useKonsole {
        source = utils.linkDots "yakuake/yakuakerc";
      };
    };

    dataFile = mkMerge [
      (mkIf config.variables.useKonsole {
        # Konsole settings
        "konsole/DefaultThemed.profile".source = utils.linkDots "konsole/DefaultThemed.profile";
        "konsole/Dracula.colorscheme".source =
          fetchGit {
            url = "https://github.com/dracula/konsole";
            rev = "030486c75f12853e9d922b59eb37c25aea4f66f4";
          }
          + "/Dracula.colorscheme";

        # Yakuake settings
        "yakuake/skins/Dracula".source = fetchGit {
          url = "https://github.com/dracula/yakuake";
          rev = "591a705898763167dd5aca2289d170f91a85aa56";
        };
      })
    ];
  };

  services.kdeconnect.enable = true;

  programs = {
    konsole = {
      enable = mkIf (config.variables.useKonsole) true;
      defaultProfile = "DefaultThemed";
      /*
        profiles.DefaultThemed = {
        name = "DefaultThemed";
        colorScheme = "Dracula";
        font = {
          name = "${config.stylix.fonts.monospace.name}";
          size = config.stylix.fonts.sizes.terminal;
        };
      };
      */
    };
    plasma = {
      enable = true;
      workspace.clickItemTo = "select";
      kwin.titlebarButtons = {
        left = ["on-all-desktops" "keep-above-windows"];
        right = ["help" "minimize" "maximize" "close"];
      };
      shortcuts.yakuake =
        mkIf config.variables.useKonsole {toggle-window-state = "F12";};
      configFile = {
        kglobalshortcutsrc.yakuake = mkIf config.variables.useKonsole {
          "_k_friendly_name".value = "Yakuake";
        };
        kwinrc.NightColor.Active.value = true;
      };
    };
  };
}
