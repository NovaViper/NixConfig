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
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      push.default = "simple";
      credential.useHttpPath = true;
      difftool.prompt = false;
      diff.tool = "vimdiff";
    };
  };

  # Enable fancy git changelogs
  programs.git-cliff = {
    enable = true;
    settings = {
      header = "Changelog";
      trim = true;
    };
  };

  # Enable git authentication handler for OAuth
  programs.git-credential-oauth.enable = true;
}
