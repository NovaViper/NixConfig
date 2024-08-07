{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
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
      kwin.titlebarButtons = {
        left = ["close" "maximize" "minimize"];
        right = ["keep-above-windows" "on-all-desktops"];
      };
      shortcuts.yakuake =
        mkIf config.variables.useKonsole {toggle-window-state = "F12";};
      configFile = {
        kdeglobals = let
          # Auto switch terminal application desktop file
          terminal =
            if builtins.hasAttr "TERMINAL" config.home.sessionVariables
            then "${config.home.sessionVariables.TERMINAL}"
            else "org.kde.konsole";
        in {
          General.TerminalApplication = "${terminal}.destop";
          General.TerminalService = "${terminal}.desktop";
        };
        kglobalshortcutsrc.yakuake = mkIf config.variables.useKonsole {
          "_k_friendly_name".value = "Yakuake";
        };
        kwinrc.NightColor = {
          Active.value = true;
          EveningBeginFixed = 2000;
          LatitudeAuto = "30.51";
          LongitudeAuto = "-91.12";
          Mode = "Times";
        };
        kservicemenurc.Show = {
          "compressfileitemaction" = true;
          "extractfileitemaction" = true;
          "forgetfileitemaction" = true;
          "installFont" = true;
          "kactivitymanagerd_fileitem_linking_plugin" = true;
          "kdeconnectfileitemaction" = true;
          "kio-admin" = true;
          "makefileactions" = true;
          "mountisoaction" = true;
          "plasmavaultfileitemaction" = true;
          "runInKonsole" = true;
          "slideshowfileitemaction" = true;
          "tagsfileitemaction" = true;
          "wallpaperfileitemaction" = true;
        };
        dolphinrc = {
          ContentDisplay.UsePermissionsFormat = "CombinedFormat";
          VersionControl.enabledPlugins = "Git";
          General = {
            "AutoExpandFolders" = true;
            "FilterBar" = true;
            "ShowFullPathInTitlebar" = true;
            "ShowToolTips" = true;
            "SortingChoice" = "CaseInsensitiveSorting";
            "UseTabForSwitchingSplitView" = true;
          };
          PreviewSettings.Plugins = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
        };
      };
    };
  };
}
