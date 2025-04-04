{
  config,
  lib,
  pkgs,
  ...
}: {
  hm.programs.mcfly.enable = true;
  hm.programs.mcfly.fzf.enable = true;
  hm.programs.mcfly.keyScheme = "vim";
  hm.programs.mcfly.fuzzySearchFactor = 2;
  #hm.programs.mcfly.settings = {};
}
