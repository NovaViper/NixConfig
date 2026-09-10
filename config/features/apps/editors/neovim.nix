{
  config,
  lib,
  pkgs,
  ...
}:
let
  neovimPackage = pkgs.inputs.novavim.default;
  defaultEditor = config.vars.apps.editor.name == "neovim";
  vars = {
    EDITOR = lib.mkIf defaultEditor (lib.mkOverride 900 "nvim");
    VISUAL = lib.mkIf defaultEditor (lib.mkOverride 900 "nvim");

  };
in
{
  vars.apps.editor = {
    name = lib.mkDefault "neovim";
    desktopFile = lib.mkDefault "nvim";
  };

  environment.variables = vars;
  hm.home.sessionVariables = vars;

  hm.home.shellAliases.vimdiff = "nvim -d";

  hm.programs.fish.shellAbbrs.n = "nvim";
  hm.programs.zsh.zsh-abbr.abbreviations.n = "nvim";

  hm.home.packages = lib.singleton neovimPackage;
}
