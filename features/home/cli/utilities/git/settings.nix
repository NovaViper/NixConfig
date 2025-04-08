{
  config,
  lib,
  pkgs,
  ...
}: {
  hm.programs.git.extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = true;
    fetch.prune = true;
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
}
