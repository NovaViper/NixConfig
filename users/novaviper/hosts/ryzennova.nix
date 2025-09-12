{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  user = "novaviper";
  hm-config = config.hm;
in
{
  #hm.home.packages = with pkgs; [digikam];

  hm.xdg.configFile = {
    "OpenRGB/plugins/settings/effect-profiles/default".source = myLib.dots.getDotsPath {
      inherit user;
      path = "openrgb/rgb-default-effect.json";
    };
    "OpenRGB/plugins/settings/EffectSettings.json".source = myLib.dots.getDotsPath {
      inherit user;
      path = "openrgb/rgb-effect-settings.json";
    };
  };

  hm.programs.rio.settings.window = {
    width = 1000;
    height = 600;
  };
}
