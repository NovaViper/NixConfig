{ config, lib, pkgs, ... }:

{
  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        prettybat
      ];
      config = { map-syntax = [ ".ignore:Git Ignore" "*.conf:INI" ]; };
    };

    fzf.fileWidgetOptions = lib.mkIf (config.programs.fzf.enable)
      (lib.mkBefore [ "--preview '${pkgs.bat}/bin/bat -n --color=always {}'" ]);
  };
}
