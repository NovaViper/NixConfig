{ config, lib, pkgs, ... }:

{
  imports = [ ../common ];

  xdg.portal.configPackages = lib.mkDefault [ pkgs.xfce.xfce4-session ];

  variables.desktop.environment = "xfce";

  #xfconf.settings = {};

  home = {
    packages = with pkgs; [ qt5ct qt6ct ];
    sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  };

}
