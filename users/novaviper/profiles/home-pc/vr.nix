{
  config,
  lib,
  myLib,
  ...
}:
let
  myself = "novaviper";
  hm-config = config.hm;
in
{
  hm.xdg.configFile = lib.mkIf (config.features.vr == "alvr") {
    "alvr/session.json" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "alvr/session.json";
    };
  };
}
