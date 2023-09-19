{ config, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    joypixels
    fira-code
    fira-code-symbols
    hack-font
    dejavu_fonts
    nerdfonts
    meslo-lg
    meslo-lgs-nf
  ];
}
