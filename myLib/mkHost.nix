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
      stateVersion ? throw "stateVersion must be set for ${hostname}",
      profiles ? [ ],
    }:
    lib.nixosSystem {
      inherit system;
      # Make sure we pass everything from the flake inputs and from the mkHost parameters
      specialArgs = flake // {
        inherit
          hostname
          username
          system
          stateVersion
          ;
      };
      modules =
        myLib.slimports {
          paths = lib.flatten [
            ../base

            # Import a premade set of options from profiles
            (map (p: ../hosts/profiles/${p}) profiles)

            # Host machine
            ../hosts/${hostname}/config
            ../hosts/${hostname}/features.nix
            ../hosts/${hostname}/hardware-configuration.nix
            ../hosts/${hostname}/hostVars.nix

            # Primary User
            ../users/${username}/system.nix
          ];
          optionalPaths = lib.flatten [
            # Import a premade set of options from profiles for users
            (map (p: ../users/${username}/profiles/${p}) profiles)

            #../users/${username}/config
            ../users/${username}/hosts/${hostname}.nix
          ];
        }
        ++ self.nixosModules.default;
    };
in
mkHost
