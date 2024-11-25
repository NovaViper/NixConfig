{
  config,
  lib,
  pkgs,
  username,
  osConfig,
  ...
}: let
  hm-config = config.hm;
in {
  hm.xdg.configFile = {
    "OpenRGB/plugins/settings/effect-profiles/default".source = lib.dots.getDotsPath {
      user = username;
      path = "openrgb/rgb-default-effect.json";
    };
    "OpenRGB/plugins/settings/EffectSettings.json".source = lib.dots.getDotsPath {
      user = username;
      path = "openrgb/rgb-effect-settings.json";
    };
  };

  hm. programs.rio.settings.window = {
    width = 1000;
    height = 600;
  };
}
