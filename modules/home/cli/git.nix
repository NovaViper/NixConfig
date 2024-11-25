{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "git" {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userEmail = lib.mkDefault (throw "programs.git.userEmail is not set");
    userName = lib.mkDefault (throw "programs.git.userName is not set");
    lfs.enable = true;
    ignores = [".direnv" "result"];
  };

  programs.git.aliases = {
    p = "pull --ff-only";
    ff = "merge --ff-only";
    graph = "log --decorate --oneline --graph";
    pushall = "!git remote | xargs -L1 git push --all";
    add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
  };

  programs.git.extraConfig = {
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
