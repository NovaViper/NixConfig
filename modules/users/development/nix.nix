{
  outputs,
  config,
  pkgs,
  ...
}: let
  alejandra-quiet = pkgs.writeShellScriptBin "alejandra-quiet" ''
    alejandra --quiet "$@"
  '';
in
  outputs.lib.mkModule config "nix" {
    programs.nix-index-database.comma.enable = true;

    home.packages = with pkgs; [
      # Nix Tools
      nh # Nice wrapper for NixOS and HM
      alejandra # Nix formatter
      nix-output-monitor # Monitor Nix compilation
      nixpkgs-review # Review nixpkgs
      nix-prefetch-github # Prefetch tool for Github
      nix-init # Automatically create nix packages from URLs
      nix-inspect # View nix configurations
      nil # Nix LSP
      deadnix # Deadcode finder for NIx
      statix # Anti-pattern detector

      alejandra-quiet # Wrapper for Emacs
    ];
  }
