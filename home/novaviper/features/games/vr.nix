{
  config,
  lib,
  pkgs,
  ...
}: let
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
in {
  xdg = {
    desktopEntries = lib.mkMerge [
      (lib.mkIf (config.variables.useVR) {
        "BeatSaberModManager" = {
          name = "Beat Saber ModManager";
          genericName = "Game";
          exec = "BeatSaberModManager";
          icon = "${pkgs.BeatSaberModManager}/lib/BeatSaberModManager/Resources/Icons/Icon.ico";
          type = "Application";
          categories = ["Game"];
          startupNotify = true;
          comment = "Beat Saber ModManager is a mod manager for Beat Saber";
        };
      })
    ];

    configFile = lib.mkIf (config.variables.useVR) {
      "alvr/session.json" = lib.mkIf (config.variables.useVR) {
        source = utils.linkDots "alvr/session.json";
      };
      #"openxr/1/active_runtime.json".source = utils.linkDots "alvr/active_runtime.json";
    };
  };
}
