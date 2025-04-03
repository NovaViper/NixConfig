{
  config,
  lib,
  myLib,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
in {
  hm.xdg.configFile = lib.mkIf config.modules.alvr.enable {
    "alvr/session.json" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "alvr/session.json";
    };
  };
}
