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

  hm.home.packages = with pkgs; [moonlight-qt];

  hm.programs.plasma.input.keyboard.options = ["caps:ctrl_modifier"];

  #hm.programs.plasma.input.touchpads = [];

  hm.programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
