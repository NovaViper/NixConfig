{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{

  # imports = myLib.utils.importFeatures {};

  vars.host = {
    configDirectory = "/home/novaviper/Projects/NixConfig";
    scalingFactor = 1.40;
  };

  vars.desktop.profile = "minimal";

  # Persistent starting scale; wdisplays can adjust it during the session.
  hm.programs.umbriel.settings.output."eDP-1".scale = lib.mkDefault config.vars.host.scalingFactor;

  hm.home.packages = with pkgs; [ moonlight-qt ];

  hm.programs.plasma.input.keyboard.options = [ "caps:ctrl_modifier" ];

  #hm.programs.plasma.input.touchpads = [];

  hm.programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
