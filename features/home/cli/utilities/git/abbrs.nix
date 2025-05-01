_:
let
  abbrs = {
    g = "git";
    gcl = "git clone";
    gs = "git status";
    gc = "git commit";
    gl = "git log";
    gp = "git push";
    gpl = "git pull";

    ga = "git add .";
    gn = "git unstage ."; # Alias of `git restore --staged`

    gd = "git diff"; # unstaged changes
    gds = "git diff --staged"; # staged changes

    gfs = "git force"; # Force push via custom alias
    grw = "git reword";
    gam = "git amend";

    ganf = "git add -AN"; # Add all new files
    gunf = "git unstage-new-files"; # Alias, unstage new file existence

    ghr = "git hire"; # Add staged changes
    gfr = "git fire"; # Unstage staged changes via patch
    gkl = "git kill"; # Delete unstaged changes

    grb = "git rebase";
    grbm = "git rebase main";
    grbma = "git rebase master";

    grbc = "git rebase --continue";
    grba = "git rebase --abort";
  };
in
{
  programs.fish.shellAbbrs = abbrs // {
    # `grbi 2` will rebase from last 2 commits
    grbi = {
      setCursor = true;
      expansion = "git rebase -i HEAD~%";
    };
  };

  programs.zsh.zsh-abbr.abbreviations = abbrs // {
    # `grbi 2` will rebase from last 2 commits
    grbi = "git rebase -i HEAD~%";
  };
}
