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
  imports = myLib.utils.importFeatures {
    hardware = [
      "qmk"
      "openrgb"
    ];
    apps = [
      "libvirt"
      "obs-studio"
    ];
    services = [
      "sunshine-server"
      "wivrn"
    ];
  };

  features.includeMinecraftServer = true;
  #hm.home.packages = with pkgs; [digikam];

  vars.desktop.profile = "full";

  vars.host = {
    configDirectory = "/home/novaviper/Projects/NixConfig";
    scalingFactor = 1;
  };

  hm.xdg.configFile = {
    "OpenRGB/plugins/settings/effect-profiles/default".source =
      myLib.dots.getDotsPath "openrgb/rgb-default-effect.json";
    "OpenRGB/plugins/settings/EffectSettings.json".source =
      myLib.dots.getDotsPath "openrgb/rgb-effect-settings.json";
  };

  hm.programs.rio.settings.window = {
    width = 1000;
    height = 600;
  };
}
