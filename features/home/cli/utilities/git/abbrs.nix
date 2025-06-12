_:
let
  cursorAbbr = expansion: {
    inherit expansion;
    setCursor = true;
  };

  abbrs = {
    g = "git";
    gcl = "git clone";
    gin = "git init";

    # Most commonly-run git commands get two letters
    gs = "git status";
    gc = "git commit";
    gn = "git unstage ."; # Alias of `git restore --staged`
    gl = "git log";
    gp = "git push";

    ga = "git add .";
    gac = "git commit .";

    gd = "git pdiff"; # Staged changes if anything is staged. If not, unstaged changes.
    gdu = "git diff"; # Unstaged changes
    gds = "git diff --staged"; # Staged changes

    gsw = "git switch";
    gswc = "git switch -c";
    gswm = "git switch main";
    gswma = "git switch master";

    gpl = "git pull";
    gplum = "git pull upstream main";
    gpluma = "git pull upstream master";

    gfs = "git force"; # Force push via custom alias

    grw = "git reword";

    gam = "git amend";
    gamp = "git amend --patch";

    ganf = "git add -AN"; # Add all new files
    gunf = "git unstage-new-files"; # Alias, unstage new file existence

    gbr = "git pbranch"; # Call our alias for `git branch` that adds formatting
    gbrd = "git branch -d";

    # Switch branches using custom alias with fzf
    gswp = "git pswitch";

    gsh = "git stash --staged";
    gshu = "git stash -k -u"; # Stash everything that isn't staged
    gsha = "git stash -u"; # Stash everything
    gshl = "git stash list --patch";
    gshp = "git stash pop";

    # Using our custom patch-based git aliases
    ghr = "git hire"; # Add staged changes
    gfr = "git fire"; # Unstage staged changes via patch
    gkl = "git kill"; # Delete unstaged changes

    ghs = "git history"; # Same as `git log --patch`, just an alias for intuition

    grb = "git rebase";
    grbm = "git rebase main";
    grbma = "git rebase master";
    grbc = "git rebase --continue";
    grba = "git rebase --abort";

    gre = "git reset";
    greh = "git reset --hard";

    grm = "git remote -v";
    grmau = "git remote add upstream";

    gfe = "git fetch";
    gfeu = "git fetch upstream";

    gud = "git undo";
    gpr = "git pr";

    gpa = "git push origin && git push mirror1 && git push mirror2";
    gpm = "git push mirror1 && git push mirror2";
  };
in
{
  programs.fish.shellAbbrs = abbrs // {
    gcm = cursorAbbr "git commit -m \"%\"";
    # `grbi 2` will rebase from last 2 commits
    grbi = cursorAbbr "git rebase -i HEAD~%";
    gpru = cursorAbbr "git pr % upstream";
  };

  programs.zsh.zsh-abbr.abbreviations = abbrs // {
    gcm = "git commit -m \"%\"";
    # `grbi 2` will rebase from last 2 commits
    grbi = "git rebase -i HEAD~%";
    gpru = "git pr % upstream";
  };
}
