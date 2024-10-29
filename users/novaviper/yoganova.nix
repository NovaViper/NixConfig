{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [moonlight-qt];

  programs.rio.settings.window = {
    width = 1200;
    height = 800;
  };
}
