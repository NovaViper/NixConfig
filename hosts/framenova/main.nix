{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{

  # imports = myLib.utils.importFeatures {};

  hostVars = {
    configDirectory = "/home/novaviper/Projects/NixConfig";
    scalingFactor = 1.40;
  };

  hm.home.packages = with pkgs; [ moonlight-qt ];

  hm.programs.plasma.input.keyboard.options = [ "caps:ctrl_modifier" ];

  #hm.programs.plasma.input.touchpads = [];

  hm.programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
