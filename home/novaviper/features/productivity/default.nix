{ config, lib, pkgs, ... }:

{
  imports = [ # ./email.nix
    ./prusa-slicer.nix
    ./obs.nix
    ./eclipse.nix
    ./mpv.nix
  ];

  home.packages = with pkgs;
    [ vlc freecad openscad ]
    ++ lib.optionals (config.environment.desktop == "kde") [ libreoffice-qt ]
    ++ lib.optionals (config.environment.desktop == "xfce")
    [ libreoffice-fresh ];

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/keepassxc" ];
     };
  */
}
