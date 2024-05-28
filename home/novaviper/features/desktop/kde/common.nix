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
      overrideConfig = true;
      workspace.clickItemTo = mkDefault "select";
      kwin.titlebarButtons = {
        left = ["on-all-desktops" "keep-above-windows"];
        right = ["help" "minimize" "maximize" "close"];
      };
      panels = [
        # Windows like panel at the bottom
        {
          location = "bottom";
          height = 46;
          floating = false;
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General.icon = "nix-snowflake-white";
              };
            }
            "org.kde.plasma.pager"
            "org.kde.plasma.marginsseperator"
            {
              name = "org.kde.plasma.icontasks";
              /*
                config = {
                Genera.launchers = [
                  ""
                ];
              };
              */
            }
            "org.kde.plasma.marginsseperator"
            "org.kde.plasma.showdesktop"
          ];
        }
        {
          location = "top";
          height = 26;
          widgets = [
            "org.kde.plasma.appmenu"
            {
              digitalClock = {
                calendar.firstDayOfWeek = "sunday";
                date = {
                  enable = true;
                  position = "besideTime";
                };
                time.showSeconds = "always";
              };
            }
            {
              systemTray = {
                icons.scaleToFit = true;
                items.configs.battery.showPercentage = true;
              };
            }
          ];
        }
      ];
      shortcuts.yakuake =
        mkIf config.variables.useKonsole {toggle-window-state = "F12";};
      configFile = {
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
          "KFileDialog Settings" = {
            "Places Icons Auto-resize" = false;
            "Places Icons Static Size" = 22;
          };
          PreviewSettings.Plugins = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
        };
      };
    };
  };
}
