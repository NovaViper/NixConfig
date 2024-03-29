{ config, lib, pkgs, ... }:

{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./cava.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./nix-index.nix
    ./ssh.nix
    ./tmux.nix
    ./topgrade.nix
    ./zsh.nix
  ];

  #programs.command-not-found.enable = true;

  home.packages = with pkgs; [
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal
    cmatrix # Show off the Matrix
    timer # Cooler timer in terminal
    tree
    dmidecode
    perl
    ventoy-full # bootable USB solution
    nvd # Differ
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM
    nixpkgs-review
    tldr # better man pages
    entr # run commands when files change!
  ];
}
