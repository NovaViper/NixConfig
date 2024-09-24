{
  config,
  outputs,
  ...
}: {
  xdg.configFile = outputs.lib.mkIf config.modules.vr.enable {
    "alvr/session.json" = outputs.lib.mkDotsSymlink {
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
