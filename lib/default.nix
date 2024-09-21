flake @ {inputs, ...}: let
  core = import ./core.nix {
    inherit inputs;
    extlib = with inputs; nixpkgs.lib // home-manager.lib;
    #extlib = with inputs; nixpkgs.lib // nix-darwin.lib // home-manager.lib;
  };
in
  with inputs;
    core.deepMerge [
      nixpkgs.lib
      #nix-darwin.lib
      home-manager.lib

      core

      (core.importAndMerge [
          ./conditionals.nix
          ./dots.nix
          ./hosts.nix
          ./pkgs.nix
          ./secrets.nix
          ./state.nix
          ./users.nix
          ./utils.nix
        ]
        flake)
    ]
