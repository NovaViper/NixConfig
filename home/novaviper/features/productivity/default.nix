{ config, lib, pkgs, ... }:

{
  imports = [ # ./email.nix
    ./prusa-slicer.nix
    ./obs.nix
    #./eclipse.nix
    ./mpv.nix
  ];

  home.packages = with pkgs;
    [ openscad freecad rpi-imager blisp ]
    ++ lib.optionals (config.variables.desktop.environment == "kde")
    [ libreoffice-qt ]
    ++ lib.optionals (config.variables.desktop.environment == "xfce")
    [ libreoffice-fresh ];

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/keepassxc" ];
     };
  */
}
