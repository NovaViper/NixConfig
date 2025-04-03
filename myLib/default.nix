{
  inputs,
  self,
  ...
}: let
  lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
  myLib = (import ./default.nix) {inherit inputs self;}; # Pass around so functions in different files can call each other
  flakeNLibs = {inherit inputs self lib myLib;};

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
    secrets = import ./secrets.nix flakeNLibs;
    conds = import ./conds.nix flakeNLibs;
    dots = import ./dots.nix flakeNLibs;
    utils = import ./utils.nix flakeNLibs;
    utilMods = import ./utilMods.nix flakeNLibs;
    mkHost = import ./mkHost.nix flakeNLibs;
    mkHome = import ./mkHome.nix flakeNLibs;
    slimports = import ./slimports.nix flakeNLibs;
    mkUnfreeNixpkgs = import ./mkUnfreeNixpkgs.nix;

    # This is a function that generates an attribute by calling function you pass to it, with each system as an argument
    forEachSystem = function:
      lib.genAttrs internals.sys (system: function exports.pkgsFor.${system});

    # Supply nixpkgs for the forAllSystems function, applies overrides from the flake and allow unfree packages globally
    pkgsFor = lib.genAttrs internals.sys (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.outputs.overlays;
          config.allowUnfree = true;
        }
    );
  };
in
  exports
