{
  config,
  lib,
  pkgs,
  ...
}: {
  # Make zsh-abbr set the cursor via % syntax
  environment.variables.ABBR_SET_EXPANSION_CURSOR = 1;

  hm.programs.zsh.zsh-abbr = {
    enable = true;
    abbreviations = {
      m = "man";
      py = "python";

      n = "nix";
      nd = "nix develop";
      nr = "nix run";

      nrn = "nix run nixpkgs#%";

      nrp = "nix repl";
      nrpn = "nix repl nixpkgs"; # Basic nix repl environment with access to lib
      nrpf = "nixos-rebuild repl"; # Nix repl with all flake data

      jc = "journalctl -u";
      jcf = "journalctl --follow -u";
      jcu = "journalctl --user -u";
      jcfu = "journalctl --follow --user -u";

      g = "git";
      gst = "git status";
      glg = "git log";
      gan = "git add -AN"; # Add all untracked files
      gcl = "git clone";
      gin = "git init";

      gc = "git commit";
      gcm = "git commit -m \"%\"";

      gbr = "git branch";
      gbrd = "git branch -d";

      gps = "git push";
      gpl = "git pull";

      # Quickly push to mirror repos for flake repo
      gpa = "git push origin && git push --mirror mirror1 && git push --mirror mirror2";
      gpm = "git push --mirror mirror1 && git push --mirror mirror2";

      gsw = "git switch";
      gswm = "git switch main";
      gswma = "git switch master";
      gswc = "git switch -c";

      grb = "git rebase";
      grbi = "git rebase -i HEAD~%"; # `grbi 2` will rebase from last 2 commits
      grbc = "git rebase --continue";
      grba = "git rebase --abort";

      gfs = "git force";

      grw = "git reword";
      grwm = "git reword --message"; # Get ready with me :3

      gam = "git amend";
      gamp = "git amend --patch";

      ghs = "git history";
    };
  };
}
