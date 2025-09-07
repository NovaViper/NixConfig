{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  user = "novaviper";
in
{
  hm.home.packages = with pkgs; [ moonlight-qt ];

  hm.programs.plasma.input.keyboard.options = [ "caps:ctrl_modifier" ];

  #hm.programs.plasma.input.touchpads = [];

  hm.programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
