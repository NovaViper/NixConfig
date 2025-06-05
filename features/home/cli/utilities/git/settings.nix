_: {
  # Force default values via `initContent` instead of `extraConfig`
  programs.git.iniContent = {
    init.defaultBranch = "main"; # Set the default name to
    rerere.enabled = true; # Reuse merge conflict fixes when rebasing
    push.autoSetupRemote = true; # Automatically track remote branch
    fetch.prune = true;

    commit.verbose = true; # show changes when writing commit message so we remember what we changed

    diff.algorithm = "histogram";
    diff.renames = "copies"; # Be as smart for renames as possible
    diff.colorMoved = true; # Make moved files a different color

    apply.whitespace = "error"; # Handle whitespace issues
    diff.wsErrorHighlight = "all"; # Highlight all whitespace errors, not just new ones

    pull.ff = "only"; # Prevent merging if changes are trivial, but if they're not, require an explicit merge
    push.useForceIfIncludes = true;
    push.default = "current"; # Only push current branch, and don't force-push everything when force pushing

    branch.sort = "-committerdate";
    log.abbrevCommit = true; # Show short version of commit hashes by default
    column.ui = "auto";
    credential.useHttpPath = true;
    log.date = "iso";

    rebase.autoSquash = true; # Treat commits with prepend messages (squash! fixup!) as they should be

    merge.conflictstyle = "diff3";
    merge.directoryRenames = true; # Renamed directories don't cause a merge conflict

  };
}
