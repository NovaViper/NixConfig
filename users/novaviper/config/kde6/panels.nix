{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [plasma-panel-colorizer];

  programs.plasma.panels = [
    # Windows like panel at the bottom
    {
      location = "bottom";
      height = 46;
      floating = false;
      widgets = [
        {
          kickoff = {
            icon = "nix-snowflake";
            sidebarPosition = "right";
            showButtonsFor = "powerAndSession";
            showActionButtonCaptions = false;
          };
        }
        "org.kde.plasma.marginsseparator"
        {
          iconTasks = {
            appearance = {
              showTooltips = true;
              highlightWindows = true;
              indicateAudioStreams = true;
              fill = true;
            };
            launchers = let
              # Auto switch terminal application desktop file
              terminal =
                if builtins.hasAttr "TERMINAL" config.home.sessionVariables
                then "${config.home.sessionVariables.TERMINAL}"
                else "org.kde.konsole";
            in [
              "preferred://browser"
              "applications:systemsettings.desktop"
              "preferred://filemanager"
              "applications:${terminal}.desktop"
              "applications:emacsclient.desktop"
              "applications:org.kde.krita.desktop"
              "applications:writer.desktop"
            ];
          };
        }
        "org.kde.plasma.marginsseparator"
        "org.kde.plasma.pager"
        "org.kde.plasma.showdesktop"
      ];
    }
    {
      location = "top";
      height = 26;
      floating = true;
      widgets = [
        {
          applicationTitleBar = {
            layout.elements = [];
            windowControlButtons = {
              iconSource = "breeze";
              buttonsAspectRatio = 95;
              buttonsMargin = 0;
            };
            windowTitle = {
              source = "appName";
              hideEmptyTitle = true;
              undefinedWindowTitle = "";
              margins = {
                left = 5;
                right = 5;
              };
            };
            overrideForMaximized = {
              enable = true;
              elements = ["windowCloseButton" "windowMaximizeButton" "windowMinimizeButton" "windowIcon" "windowTitle"];
              source = "appName";
            };
          };
        }
        "org.kde.plasma.appmenu"
        "org.kde.plasma.panelspacer"
        {
          digitalClock = {
            date = {
              enable = true;
              position = "besideTime";
            };
            time.showSeconds = "always";
          };
        }
        "org.kde.plasma.panelspacer"
        {
          systemTray = {
            icons.scaleToFit = true;
            items = {
              shown = [
                "org.kde.plasma.battery"
              ];
              configs.battery.showPercentage = true;
            };
          };
        }
      ];
    }
  ];
}
