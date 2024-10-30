{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "bat" {
  # Fancy 'cat' replacement
  programs.bat = {
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

  programs.fzf.fileWidgetOptions = lib.mkIf config.programs.fzf.enable (lib.mkBefore ["--preview '${pkgs.bat}/bin/bat -n --color=always {}'"]);
}
