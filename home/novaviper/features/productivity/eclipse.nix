{ config, lib, pkgs, ... }:

{
  programs.eclipse = {
    enable = true;
    package = pkgs.eclipses.eclipse-java;
    enableLombok = true;
    jvmArgs = [ ];
    plugins = with pkgs.eclipses.plugins;
      [
        color-theme
        /* (buildEclipsePlugin {
             name = "";
             srcFeature = fetchurl {
               url = "";
               hash = "";
             };
             srcPlugin = fetchurl {
               url = "";
               hash = "";
             };
           })
        */
      ];
  };
}
