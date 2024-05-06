# This file should be included when using hm standalone
{outputs, ...}: {
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = import ./nixpkgs-config.nix;
  };
}
