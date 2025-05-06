{
  config,

  lib,
  myLib,
  pkgs,
  ...
}:

let
  neovimPackage = pkgs.inputs.novavim.default;
  userVars = opt: myLib.utils.getUserVars opt config;
in
{
  home.sessionVariables = lib.mkIf (userVars "defaultEditor" == "neovim") { EDITOR = "nvim"; };

  programs.fish.shellAbbrs.n = "nvim";
  programs.zsh.zsh-abbr.abbreviations.n = "nvim";

  home.packages = lib.singleton neovimPackage;

  programs.neovide = {
    enable = true;
    settings = { };
  };
}
