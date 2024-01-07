{ config, lib, pkgs, ... }:

{
  qt = lib.mkMerge [
    (lib.mkIf (config.variables.desktop.environment == "kde") {
      enable = true;
      platformTheme = "kde";
    })
    (lib.mkIf (config.variables.desktop.environment == "xfce") {
      enable = true;
      platformTheme = "qtct";
    })
  ];
}
