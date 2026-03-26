{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  neovimPackage = pkgs.inputs.novavim.default;
  userVars = opt: myLib.utils.getUserVars opt hm-config;
in
{
  hm.home.sessionVariables = lib.mkIf (userVars "defaultEditor" == "neovim") {
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
