{outputs, ...}: {
  nixpkgs = {
    config = import ./nixpkgs-config.nix;
    overlays = builtins.attrValues outputs.overlays;
  };
}
