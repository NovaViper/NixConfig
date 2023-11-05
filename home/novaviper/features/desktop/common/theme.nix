{ config, pkgs, lib, ... }:

{
  /* gtk = {
       enable = true;
       gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
       theme = {
         name = "Dracula";
         package = pkgs.dracula-theme;
       };
       iconTheme.name = "Dracula";
     };

     qt = lib.mkMerge [
       (lib.mkIf (config.variables.desktop.environment == "kde") {
         enable = true;
         platformTheme = "kde";
       })
       (lib.mkIf (config.variables.desktop.environment == "xfce") {
         enable = true;
         platformTheme = "qtct";
         style = {
           name = "Dracula";
           package = pkgs.dracula-theme;
         };
       })
     ];
  */

  home = {
    sessionVariables.GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    packages = with pkgs; [ dracula-icon-theme dracula-theme ];
  };
}
