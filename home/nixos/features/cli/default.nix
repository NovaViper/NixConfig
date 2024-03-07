{ config, lib, pkgs, ... }:

{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./nix-index.nix
    ./zsh.nix
  ];

  #programs.command-not-found.enable = true;

  home.packages = with pkgs; [
    fastfetch
    tree
    dmidecode
    nvd # Differ
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM
    nixpkgs-review
    perl
  ];
}
