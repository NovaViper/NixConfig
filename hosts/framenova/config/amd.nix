{
  config,
  lib,
  pkgs,
  ...
}:
let
  enableAMD =
    packages:
    (
      final: prev:
      builtins.listToAttrs (
        map (pkgName: {
          name = pkgName;
          value = prev.${pkgName}.override {
            rocmSupport = true;
          };
        }) packages
      )
    );
in
{
  # Enable proper AMD GPU support for various packages
  nixpkgs.overlays = lib.singleton (enableAMD [
    "btop"
  ]);
}
