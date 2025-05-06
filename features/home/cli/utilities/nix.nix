{ pkgs, ... }:
{
  programs.nix-index-database.comma.enable = true;

  programs.nix-your-shell.enable = true;

  home.packages = with pkgs; [
    nh # Nice wrapper for NixOS and HM
    nixfmt-rfc-style # Nix formatter
    nix-output-monitor # Monitor Nix compilation
    nvd # Nix/NixOS package version diff tool
    nixpkgs-review # Review nixpkgs
    nurl # Automated prefetch tool for
    nix-init # Automatically create nix packages from URLs
    nix-inspect # View nix configurations
    nil # Nix LSP
    nixd # Another Nix LSP
    deadnix # Deadcode finder for NIx
    statix # Anti-pattern detector
  ];
}
