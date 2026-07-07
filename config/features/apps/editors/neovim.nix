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
  hm.home.sessionVariables = lib.mkIf (config.vars.apps.editor == "neovim") {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  hm.home.shellAliases.vimdiff = "nvim -d";

  hm.programs.fish.shellAbbrs.n = "nvim";
  hm.programs.zsh.zsh-abbr.abbreviations.n = "nvim";

  hm.home.packages = lib.singleton neovimPackage;

  hm.programs.neovide = {
    enable = true;
    settings = { };
  };
}
