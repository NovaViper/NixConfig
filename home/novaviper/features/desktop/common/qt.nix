{ config, lib, pkgs, ... }:

{
  qt = lib.mkMerge [
    (lib.mkIf (config.variables.desktop.environment
      == "kde") { # Must be disabled because it completely breaks Plasma 6!!
        enable = lib.mkForce false;
      })
    (lib.mkIf (config.variables.desktop.environment == "xfce") {
      enable = true;
      platformTheme = "qtct";
    })
  ];
}
