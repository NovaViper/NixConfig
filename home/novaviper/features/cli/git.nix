{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "NovaViper";
    userEmail = "coder.nova99@mailbox.org";
    signing = {
      key = "DEAB6E5298F9C516";
      signByDefault = true;
    };
    extraConfig = {
      pull = { rebase = true; };
      fetch = { prune = true; };
      push = { default = "simple"; };
      credential = { useHttpPath = true; };
      difftool = { prompt = true; };
      diff = { tool = "${pkgs.kdiff3}/bin/kdiff3"; };
    };
  };
}
