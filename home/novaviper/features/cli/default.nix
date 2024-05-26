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
    ./fastfetch.nix
    ./fd.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./navi.nix
    ./nix-index.nix
    ./ssh.nix
    ./tmux.nix
    ./topgrade.nix
    ./zsh.nix
    ./wrappers.nix
  ];

  #programs.command-not-found.enable = true;

  home.packages = with pkgs; [
    # Terminal Decorations
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal

    # Fancy utilities
    timer # Cooler timer in terminal
    tldr # better man pages
    entr # run commands when files change!
    procs # Better ps
    ventoy-full # bootable USB solution

    # Nix Tools
    nh # Nice wrapper for NixOS and HM
    alejandra # Nix formatter
    nix-output-monitor # Monitor Nix compilation
    nixpkgs-review # Review nixpkgs
    nix-prefetch-github # Prefetch tool for Github
    nix-init # Automatically create nix packages from URLs
    nix-inspect # View nix configurations
    nil # Nix LSP
  ];
}
