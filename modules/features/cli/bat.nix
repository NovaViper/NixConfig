{
  config,
  lib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in
  lib.utilMods.mkModule config "bat" {
    # Fancy 'cat' replacement
    hm.programs.bat = {
      enable = true;

      config.map-syntax = [".ignore:Git Ignore" "*.conf:INI"];

      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        prettybat
      ];
    };

    hm.programs.fzf.fileWidgetOptions = lib.mkIf hm-config.programs.fzf.enable (lib.mkBefore ["--preview '${pkgs.bat}/bin/bat -n --color=always {}'"]);
  }
