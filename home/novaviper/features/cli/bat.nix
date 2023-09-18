{ config, lib, pkgs, ... }:

{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batpipe
      prettybat
    ];
    config = {
      theme = "Dracula";
      map-syntax = [ ".ignore:Git Ignore" "*.conf:INI" ];
    };
  };
}
