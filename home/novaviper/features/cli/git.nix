{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "NovaViper";
    userEmail = "coder.nova99@mailbox.org";
    aliases = {graph = "log --decorate --online --graph";};
    signing = {
      key = "DEAB6E5298F9C516";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
      credential.useHttpPath = true;
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";
      diff.algorithm = "histogram";
      # Automatically track remote branch
      push.autoSetupRemote = true;
      # Reuse merge conflict fixes when rebasing
      rerere.enabled = true;
    };
    lfs.enable = true;
    ignores = [".direnv" "result"];
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
