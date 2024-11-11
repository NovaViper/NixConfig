{
  config,
  osConfig,
  lib,
  ...
}: {
  xdg.configFile = lib.mkIf osConfig.modules.alvr.enable {
    "alvr/session.json" = lib.dots.mkDotsSymlink {
      inherit config;
      user = config.home.username;
      source = "alvr/session.json";
    };
  };
}
