{ config, lib, pkgs, ... }:

{
  imports = [ # ./email.nix
    ./prusa-slicer.nix
    ./obs.nix
    ./eclipse.nix
    ./mpv.nix
  ];

  home.packages = with pkgs;
    [ vlc freecad ]
    ++ lib.optionals (config.environment.desktop == "kde") [ libreoffice-qt ]
    ++ lib.optionals (config.environment.desktop == "xfce")
    [ libreoffice-fresh ];
}
