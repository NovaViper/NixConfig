{ config, lib, pkgs, ... }:

{
  imports = [
    ./bat.nix
    ./btop.nix
    ./eza.nix
    ./git.nix
    ./topgrade.nix
    ./gpg.nix
    ./ssh.nix
    ./zsh.nix
    ./nix-index.nix
    ./tmux.nix
    ./cava.nix
  ];

  #programs.command-not-found.enable = true;

  home.packages = with pkgs; [
    toilet # Display fancy text in terminal
    dwt1-shell-color-scripts # Display cool graphics in terminal
    cmatrix # Show off the Matrix
    timer # Cooler timer in terminal
    tree
    inputs.nh.default # nixos-rebuild and home-manager CLI wrapper
    dmidecode
    ventoy-full # bootable USB solution
    nixpkgs-review
  ];
}
