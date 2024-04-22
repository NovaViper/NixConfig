{
  config,
  lib,
  pkgs,
  ...
}: {
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
    ./wrappers.nix
  ];

  #programs.command-not-found.enable = true;

  home.packages = with pkgs; [
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal
    cmatrix # Show off the Matrix
    timer # Cooler timer in terminal
    tree
    tldr # better man pages
    entr # run commands when files change!
    dmidecode
    perl
    ventoy-full # bootable USB solution

    # Nix Tools
    alejandra # Nix formatter
    nvd # Differ
    nix-output-monitor # Monitor Nix compilation
    nh # Nice wrapper for NixOS and HM
    nixpkgs-review # Review nixpkgs
    nix-prefetch-github # Prefetch tool for Github
    nix-init # Automatically create nix packages from URLs
    nix-inspect # View nix configurations
  ];
}
