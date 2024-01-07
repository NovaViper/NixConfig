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
      theme = "${config.theme.name}";
      map-syntax = [ ".ignore:Git Ignore" "*.conf:INI" ];
    };
  };
}
