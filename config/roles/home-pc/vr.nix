{
  config,
  lib,
  myLib,
  ...
}:
{
  hm.xdg.configFile = lib.mkIf (config.features.vr == "alvr") {
    "alvr/session.json" = myLib.dots.mkDotsSymlink {
      inherit config;
      source = "alvr/session.json";
    };
  };
}
