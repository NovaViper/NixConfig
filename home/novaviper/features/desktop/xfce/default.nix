{ config, lib, pkgs, ... }:

{
  imports = [ ../common ];

  environment.desktop = "xfce";

  #xfconf.settings = {};

  home = {
    packages = with pkgs; [ qt5ct qt6ct ];
    sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  };

}
