{ config, lib, pkgs, ... }:

{
  imports = [ ../common ];

  variables.desktop.environment = "xfce";

  #xfconf.settings = {};

  home = {
    packages = with pkgs; [ qt5ct qt6ct ];
    sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  };

}
