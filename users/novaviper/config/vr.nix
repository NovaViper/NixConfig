{
  config,
  osConfig,
  lib,
  ...
}: {
  xdg.configFile = lib.mkIf osConfig.modules.gaming.vr.enable {
    "alvr/session.json" = lib.dots.mkDotsSymlink {
      inherit config;
      user = config.home.username;
      source = "alvr/session.json";
    };
    /*
      "openxr/1/active_runtime.json"= outputs.lib.mkDotsSymlink {
      config = config;
      user = config.home.username;
      source = "alvr/active_runtime.json";
    };
    */
  };
}
