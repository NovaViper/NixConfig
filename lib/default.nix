flake @ {
  inputs,
  self,
  lib,
  ...
}: let
  # Helper functions we don't plan on exporting past this file
  internals = {
    # Supported systems for your flake packages, shell, etc are determined by the systems input.
    sys = import inputs.systems;
  };

  exports = {
    # Paths used for various parts of the flake and lib functions
    flakePath = config: "${config.home.sessionVariables.FLAKE}";
    dotsPath = user: "${user}/dotfiles";

    # Import functions for library
    secrets = import ./secrets.nix flake;
    conds = import ./conds.nix flake;
    dots = import ./dots.nix flake;
    mkUnfreeNixpkgs = import ./mkUnfreeNixpkgs.nix;
    #forEachSystem = import ./forEachSystem.nix flake;
    #pkgsFor = import ./pkgsFor.nix flake;
    utils = import ./utils.nix flake;
    utilMods = import ./utilMods.nix flake;
    mkHost = import ./mkHost.nix flake;
    mkHome = import ./mkHome.nix flake;

    # This is a function that generates an attribute by calling function you pass to it, with each system as an argument
    forEachSystem = function:
      lib.genAttrs internals.sys (system: function exports.pkgsFor.${system});

    # Supply nixpkgs for the forAllSystems function, applies overrides from the flake and allow unfree packages globally
    pkgsFor = lib.genAttrs internals.sys (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues inputs.self.outputs.overlays;
          config.allowUnfree = true;
        }
    );
  };
in
  exports
