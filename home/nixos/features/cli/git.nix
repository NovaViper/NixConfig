{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = { graph = "log --decorate --online --graph"; };
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
      difftool.prompt = false;
      diff = {
        tool = "vimdiff";
        algorithm = "histogram";
      };
      push = {
        default = "simple";
        # Automatically track remote branch
        autoSetupRemote = true;
      };
      # Reuse merge conflict fixes when rebasing
      rerere.enabled = true;
    };
    lfs.enable = true;
    ignores = [ ".direnv" "result" ];
  };

  # Enable git authentication handler for OAuth
  programs.git-credential-oauth.enable = true;
}
