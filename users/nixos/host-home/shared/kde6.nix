{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  programs.plasma.enable = true;

  programs.plasma.panels = [
    {
      floating = true;
      location = "bottom";
      widgets = [
        {
          kickoff = {
            sortAlphabetically = true;
            icon = "plasma-symbolic";
          };
        }
        {
          iconTasks = {
            appearance = {
              showTooltips = true;
              highlightWindows = true;
              indicateAudioStreams = true;
              fill = true;
            };
            launchers =
              let
                # Auto switch terminal application desktop file
                terminal = myLib.utils.getTerminalDesktopFile config;
              in
              [
                "preferred://browser"
                "applications:systemsettings.desktop"
                "preferred://filemanager"
                "applications:${terminal}.desktop"
              ];
          };
        }
        "org.kde.plasma.marginsseparator"
        {
          systemTray.items = {
            shown = [
              "org.kde.plasma.battery"
              "org.kde.plasma.bluetooth"
            ];
          };
        }
        "org.kde.plasma.digitalclock"
      ];
    }
  ];
}
