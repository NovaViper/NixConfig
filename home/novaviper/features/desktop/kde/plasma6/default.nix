{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [../common.nix];

  services.kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;

  # Add Firefox native messaging host support for Plasma Integration
  programs = {
    firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];
    plasma = {
      extraWidgets = ["application-title-bar"];
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
            "org.kde.plasma.marginsseparator"
            {
              name = "org.kde.plasma.icontasks";

              config = {
                Genera.launchers = let
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
                windowControlButtons = {
                  iconSource = "Breeze";
                  buttonsAspectRatio = 95;
                  buttonsMargin = 0;
                };
                windowTitle = {
                  source = "AppName";
                  hideEmptyTitle = true;
                  undefinedWindowTitle = "";
                  margins = {
                    left = 5;
                    right = 5;
                  };
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
    };
  };
}
