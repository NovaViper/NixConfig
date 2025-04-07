{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "off";
        inhibit_screensaver = 1;
      };
      custom = {
        start = "''${lib.getExe pkgs.libnotify} 'GameMode started'";
        end = "''${lib.getExe pkgs.libnotify} 'GameMode ended'";
      };
    };
  };
}
