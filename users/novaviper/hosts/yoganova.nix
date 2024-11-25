{
  config,
  lib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
  hm.home.packages = with pkgs; [moonlight-qt];

  hm.programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
