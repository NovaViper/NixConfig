{
  osConfig,
  config,
  lib,
  myLib,
  ...
}: let
  myself = "novaviper";
in {
  xdg.configFile = lib.mkIf (osConfig.features.vr == "alvr") {
    "alvr/session.json" = myLib.dots.mkDotsSymlink {
      config = config;
      user = myself;
      source = "alvr/session.json";
    };
  };
}
