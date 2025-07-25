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
      primaryUser ? throw "a primary user must be set for ${hostname}",
      extraUsers ? [ ],
      system ? throw "system must be set for ${hostname}",
      stateVersion ? throw "stateVersion must be set for ${hostname}",
    }:
    let
      # Combine the users into one list, easier to reference them all at once
      allUsers = [ primaryUser ] ++ extraUsers;
    in
    lib.nixosSystem {
      inherit system;
      # Make sure we pass everything from the flake inputs and from the mkHost parameters
      specialArgs = flake // {
        inherit
          hostname
          primaryUser
          extraUsers
          allUsers
          system
          stateVersion
          ;
      };
      modules =
        myLib.slimports {
          paths = lib.flatten [
            ../core

            # Host machine
            ../hosts/${hostname}/config
            ../hosts/${hostname}/features.nix
            ../hosts/${hostname}/hardware-configuration.nix
            ../hosts/${hostname}/hostVars.nix

            # Primary User
            ../users/${primaryUser}/core-os
            # Extra User(s)
            (map (u: ../users/${u}/core-os) extraUsers)
          ];
          optionalPaths = lib.flatten [
            # Primary User
            ../users/${primaryUser}/hosts-os/${hostname}.nix
            # Extra User(s)
            (map (u: ../users/${u}/hosts-os/${hostname}.nix) extraUsers)
          ];
        }
        ++ self.nixosModules.default;
    };
in
mkHost
