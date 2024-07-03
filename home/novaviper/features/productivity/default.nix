{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./mail.nix
    ./prusa-slicer.nix
    ./obs.nix
    #./eclipse.nix
    ./mpv.nix
  ];

  home = {
    packages = with pkgs;
      [openscad freecad rpi-imager blisp]
      # For KDE Plasma 5
      ++ lib.optionals (config.variables.desktop.environment == "kde" && config.variables.desktop.displayManager == "x11")
      [libreoffice-qt-fresh]
      # For KDE Plasma 6
      ++ lib.optionals (config.variables.desktop.environment == "kde" && config.variables.desktop.displayManager == "wayland")
      [libreoffice-qt6-fresh]
      ++ lib.optionals (config.variables.desktop.environment == "xfce")
      [libreoffice-fresh];
  };
}
