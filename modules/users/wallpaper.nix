{
  pkgs,
  outputs,
  config,
  name,
  ...
}: {
  options.wallpaper = outputs.lib.mkOption {
    default = null;
    type = outputs.lib.types.path;
  };

  config = outputs.lib.mkIf (config.wallpaper != null) {
    stylix.image = outputs.lib.mkForce config.wallpaper;
    nixos.stylix.image = outputs.lib.mkForce config.wallpaper;
  };
}
