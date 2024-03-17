{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ nur.repos.lunik1.feishin-appimage ];

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
}
