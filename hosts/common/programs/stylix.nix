{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  c = config.lib.stylix.colors.withHashtag;
  f = config.stylix.fonts;
in {
  imports = with inputs; [
    stylix.nixosModules.stylix
  ];

  environment.systemPackages =
    mkIf (config.stylix.cursor.package != null)
    [config.stylix.cursor.package];

  services.displayManager.sddm.settings = lib.mkIf (config.services.displayManager.sddm.enable) {
    General = mkIf (config.stylix.image != null) {
      background = "${config.stylix.image}";
      type = "image";
    };
    Theme = {
      CursorSize = config.stylix.cursor.size;
      CursorTheme =
        if (config.stylix.cursor != null)
        then config.stylix.cursor.name
        else "breeze_cursors";
      Font = "${f.sansSerif.name},${
        toString f.sizes.applications
      },-1,0,50,0,0,0,0,0";
    };
  };
}
