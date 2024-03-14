{ config, lib, pkgs, ... }:

{
  imports = [ # ./email.nix
    ./prusa-slicer.nix
    ./obs.nix
    #./eclipse.nix
    ./mpv.nix
  ];

  home = {
    # Libreoffice-qt fix
    sessionVariables.SAL_USE_VCLPLUGIN = "kf5";
    packages = with pkgs;
      [ openscad freecad rpi-imager blisp ]
      ++ lib.optionals (config.variables.desktop.environment == "kde")
      [ libreoffice-qt ]
      ++ lib.optionals (config.variables.desktop.environment == "xfce")
      [ libreoffice-fresh ];
  };
}
