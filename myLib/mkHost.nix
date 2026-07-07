flake@{
  inputs,
  self,
  lib,
  myLib,
  ...
}:
let
  # Helper function for creating the system config for NixOS
  mkHost =
    hostname:
    {
      username ? throw "username must be set for ${hostname}",
      system ? throw "system must be set for ${hostname}",
      stateVersion ? myLib.conds.defaultStateVersion,
      roles ? [ ],
    }:
    lib.nixosSystem {
      # Make sure we pass everything from the flake inputs and from the mkHost parameters
      specialArgs = flake // {
        inherit
          hostname
          username
          system
          stateVersion
          ;
        # Inject the host/user-bound myLib directly for module use!
        myLib = myLib.boundWith { inherit hostname username; };
      };
      modules =
        myLib.slimports {
          paths = lib.flatten [
            ../config/core

            # Import a group of features/options from a role group
            (map (r: ../config/roles/${r}) roles)

            # Host machine
            ../hosts/${hostname}/config
            ../hosts/${hostname}/hardware-configuration.nix
            ../hosts/${hostname}/main.nix

            # Primary User
            ../home/${username}/main.nix
          ];
        }
        ++ self.nixosModules.default;
    };
in
mkHost
