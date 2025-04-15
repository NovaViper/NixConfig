{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.mcfly.enable = true;
  programs.mcfly.fzf.enable = true;
  programs.mcfly.keyScheme = "vim";
  programs.mcfly.fuzzySearchFactor = 2;
  #programs.mcfly.settings = {};
}
