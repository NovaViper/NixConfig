{
  config,
  lib,
  myLib,
  ...
}: let
  hm-config = config.hm;
in {
  create.configFile = lib.mkIf config.modules.alvr.enable {
    "alvr/session.json" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "alvr/session.json";
    };
  };
}
