{
  inputs,
  self,
  ...
}:
let
  lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
  myLib = (import ./default.nix) { inherit inputs self; }; # Pass around so functions in different files can call each other
  flakeNLibs = {
    inherit
      inputs
      self
      lib
      myLib
      ;
  };

  # Helper functions we don't plan on exporting past this file
  internals = {
    # Supported systems for your flake packages, shell, etc.
    supportedSystems = [ "x86_64-linux" ];
  };

  exports = {
    # Import functions for library
    secrets = import ./secrets.nix flakeNLibs;
    conds = import ./conds.nix flakeNLibs;
    dots = import ./dots.nix flakeNLibs;
    utils = import ./utils.nix flakeNLibs;
    mkHost = import ./mkHost.nix flakeNLibs;
    mkHome = import ./mkHome.nix flakeNLibs;
    slimports = import ./slimports.nix flakeNLibs;
    mkUnfreeNixpkgs = import ./mkUnfreeNixpkgs.nix;

    # This is a function that generates an attribute by calling the function you
    # pass to it, with a list of supported system appended to the function
    forAllSystems =
      function:
      lib.genAttrs internals.supportedSystems (
        system:
        function (
          # Applies overrides from the flake and allow unfree packages globally
          import inputs.nixpkgs {
            localSystem = system;
            overlays = builtins.attrValues self.outputs.overlays;
            config.allowUnfree = true;
          }
        )
      );
  };
in
exports
// {
  # The "magic": produce a host/user aware library for use in specialArgs
  boundWith =
    { hostname, username, ... }:
    let
      dotsPath = "${username}/dotfiles";
      # Flake path handles both NixOS and home-manager-only configs.
      flakePath =
        config:
        if config ? hm then
          "${config.hm.home.sessionVariables.FLAKE}"
        else
          "${config.home.sessionVariables.FLAKE}";
    in
    exports
    // {
      inherit dotsPath flakePath;
      dots = import ./dots.nix {
        inherit
          lib
          dotsPath
          flakePath
          ;
      };
      utils = import ./utils.nix {
        inherit
          lib
          username
          hostname
          dotsPath
          flakePath
          ;
      };
    };
}
