{ config, pkgs, dotfilesLib, ... }:

{
  imports = [ ../common ];

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  xdg.mimeApps = {
    associations = {
      added = {
        "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
      };
    };
    defaultApplications = {
      "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
    };
  };

  xdg.configFile."kdiff3rc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/misc/kdiff3rc";

  environment.desktop = "kde";
}
