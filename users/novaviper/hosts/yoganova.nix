{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  myself = "novaviper";
in
{
  imports = lib.singleton ./base.nix;

  home.packages = with pkgs; [ moonlight-qt ];

  programs.plasma.input.keyboard.options = [ "caps:ctrl_modifier" ];

  #programs.plasma.input.touchpads = [];

  programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
