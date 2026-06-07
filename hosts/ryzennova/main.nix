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
  imports = myLib.utils.importFeatures [
    ### Hardware
    "hardware/qmk"
    "hardware/rgb"

    ### Service
    "services/sunshine-server"
    "services/wivrn"

    ### Applications
    "programs/libvirt"
    "programs/obs"
  ];

  features.includeMinecraftServer = true;
  #hm.home.packages = with pkgs; [digikam];

  hostVars = {
    configDirectory = "/home/novaviper/Projects/NixConfig";
    scalingFactor = 1;
  };

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
