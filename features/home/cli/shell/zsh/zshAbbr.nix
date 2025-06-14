{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zsh.localVariables = {
    # Enable reminders
    ABBR_GET_AVAILABLE_ABBREVIATION = 1;
    ABBR_LOG_AVAILABLE_ABBREVIATION = 1;
    # Make zsh-abbr set the cursor via % syntax
    ABBR_SET_EXPANSION_CURSOR = 1;
  };

  programs.zsh.zsh-abbr = {
    enable = true;
    abbreviations = {
      m = "man";
      py = "python";
      ja = "java";

      nd = "nix develop";
      nr = "nix run";
      ni = "nix-inspect";
      nie = "nix-inspect -e";
      nipa = "nix-inspect -p";

      nrn = "nix run nixpkgs#%";

      nrp = "nix repl";
      nrpn = "nix repl nixpkgs"; # Basic nix repl environment with access to lib
      nrpf = "nixos-rebuild repl"; # Nix repl with all flake data

      nf = "nix flake";
      nfu = "nix flake update";
      nfch = "nix flake check";
      nfcht = "nix flake check --show-trace";

      nhhs = "nh home switch";
      nhos = "nh os switch";
      nhot = "nh os test";

      s = "source";

      jc = "journalctl";
      jcf = "journalctl --follow -u";
      jcu = "journalctl --user -u";
      jcfu = "journalctl --follow --user -u";

      sc = "systemctl";
      scu = "systemctl --user";
    };
  };
}
