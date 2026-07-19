{
  config,
  lib,
  pkgs,
  ...
}:
let
  neovimPackage = pkgs.inputs.novavim.default;
in
{
  vars.apps.editor = {
    name = lib.mkDefault "neovim";
    desktopFile = lib.mkDefault "nvim";
  };

  hm.home.sessionVariables = lib.mkIf (config.vars.apps.editor == "neovim") {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  hm.home.shellAliases.vimdiff = "nvim -d";

  hm.programs.fish.shellAbbrs.n = "nvim";
  hm.programs.zsh.zsh-abbr.abbreviations.n = "nvim";

  hm.home.packages = lib.singleton neovimPackage;
}
