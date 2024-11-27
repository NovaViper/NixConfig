{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "latex" {
  home.packages = with pkgs; [
    # :editor format
    texlive.combined.scheme-medium #LaTex
  ];
}
