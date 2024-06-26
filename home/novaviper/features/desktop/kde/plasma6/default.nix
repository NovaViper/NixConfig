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

  home.packages = with pkgs; [
    plasma-panel-spacer-extended
    plasma-window-title-applet
  ];

  # Add Firefox native messaging host support for Plasma Integration
  programs = {
    firefox.nativeMessagingHosts = with pkgs; [kdePackages.plasma-browser-integration];

    plasma.panels = [
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
          "org.kde.windowtitle"
          "org.kde.plasma.appmenu"
          {
            name = "luisbocanegra.panelspacer.extended";
            config.General = {
              qdbusCommand = "qdbus";
              showTooltip = "false";
            };
          }
          {
            digitalClock = {
              date = {
                enable = true;
                position = "besideTime";
              };
              time.showSeconds = "always";
            };
          }
          {
            name = "luisbocanegra.panelspacer.extended";
            config.General = {
              qdbusCommand = "qdbus";
              showTooltip = "false";
            };
          }
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
}
