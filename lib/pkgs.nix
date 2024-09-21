flake @ {
  inputs,
  outputs,
  ...
}: let
  nixpkgsConfig = (import ../modules/nix/nixpkgs.nix flake).nixpkgs;

  # Supported systems for your flake packages, shell, etc are determined by the systems input.
  sys = import inputs.systems;
in rec {
  # This is a function that generates an attribute by calling function you pass to it, with each system as an argument
  forEachSystem = function:
    outputs.lib.genAttrs sys (system: function pkgsFor.${system});

  # Supply nixpkgs for the forAllSystems function, applies overrides from the flake and allow unfree packages globally
  pkgsFor = outputs.lib.genAttrs sys (
    system:
      import inputs.nixpkgs {
        inherit system;
        inherit (nixpkgsConfig) config overlays;
        #overlays = builtins.attrValues outputs.overlays;
        #config.allowUnfree = true;
      }
  );
}
