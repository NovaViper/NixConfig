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
  hmUser = lib.singleton (hm: let
    hm-config = hm.config;
  in {
    home.packages = with pkgs; [moonlight-qt];

    programs.plasma.input.keyboard.options = ["caps:ctrl_modifier"];

    #programs.plasma.input.touchpads = [];

    programs.rio.settings.window = {
      width = 1200;
      height = 800;
    };
  });
}
