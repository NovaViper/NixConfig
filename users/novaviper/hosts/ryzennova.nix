{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
in {
  imports = lib.singleton ./base.nix;

  hm.home.packages = with pkgs; [digikam];

  hm.xdg.configFile = {
    "OpenRGB/plugins/settings/effect-profiles/default".source = myLib.dots.getDotsPath {
      user = myself;
      path = "openrgb/rgb-default-effect.json";
    };
    "OpenRGB/plugins/settings/EffectSettings.json".source = myLib.dots.getDotsPath {
      user = myself;
      path = "openrgb/rgb-effect-settings.json";
    };
  };

  hm.programs.rio.settings.window = {
    width = 1000;
    height = 600;
  };
}
