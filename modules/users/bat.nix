{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkModule config "bat" {
  # Fancy 'cat' replacement
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
      config = {map-syntax = [".ignore:Git Ignore" "*.conf:INI"];};
    };

    fzf.fileWidgetOptions =
      outputs.lib.mkIf config.programs.fzf.enable
      (outputs.lib.mkBefore ["--preview '${pkgs.bat}/bin/bat -n --color=always {}'"]);
  };
}
