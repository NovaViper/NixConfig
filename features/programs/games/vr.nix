{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgFeat = config.features;
in
{
  environment.systemPackages =
    with pkgs;
    lib.optionals (cfgFeat.vr != null) [
      helvum
      bs-manager
      # For the Quest headsets
      android-tools
    ];
}
