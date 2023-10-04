{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ jellyfin-media-player ];

  /* xdg.mimeApps = {
       associations = {
         added = {
           "x-scheme-handler/ame" = "cider.desktop";
           "x-scheme-handler/cider" = "cider.desktop";
           "x-scheme-handler/itms" = "cider.desktop";
           "x-scheme-handler/itmss" = "cider.desktop";
           "x-scheme-handler/musics" = "cider.desktop";
           "x-scheme-handler/music" = "cider.desktop";
         };
       };
       defaultApplications = {
         "x-scheme-handler/ame" = "cider.desktop";
         "x-scheme-handler/cider" = "cider.desktop";
         "x-scheme-handler/itms" = "cider.desktop";
         "x-scheme-handler/itmss" = "cider.desktop";
         "x-scheme-handler/musics" = "cider.desktop";
         "x-scheme-handler/music" = "cider.desktop";
       };
     };
  */

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/jellyfin.org" ];
     };
  */
}
