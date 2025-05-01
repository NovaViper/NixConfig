{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Fancy 'cat' replacement
  programs.bat = {
    enable = true;

    config.map-syntax = [
      ".ignore:Git Ignore"
      "*.conf:INI"
    ];

    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batpipe
      prettybat
    ];
  };

  home.activation.batCache = lib.mkForce ""; # Waiting for https://github.com/nix-community/home-manager/issues/5481 is fixed

  programs.fzf.fileWidgetOptions = lib.mkIf config.programs.fzf.enable (
    lib.mkBefore [ "--preview '${pkgs.bat}/bin/bat -n --color=always {}'" ]
  );
}
