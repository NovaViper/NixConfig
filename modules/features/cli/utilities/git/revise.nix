{
  config,
  lib,
  pkgs,
  ...
}: let
  abbrs = {
    grv = "git revise";
    grvm = "git revise main";
    grvma = "git revise master";

    grvum = "git revise upstream/main";
    grvuma = "git revise upstream/master";
  };
in {
  environment.systemPackages = lib.singleton pkgs.git-revise;

  hm.programs.fish.shellAbbrs =
    abbrs
    // {
      # `grvi 2` will revise from last 2 commits
      grvi = {
        setCursor = true;
        expansion = "git revise -i HEAD~%";
      };
    };

  hm.programs.zsh.zsh-abbr.abbreviations =
    abbrs
    // {
      # `grvi 2` will revise from last 2 commits
      grvi = "git revise -i HEAD~%";
    };
}
