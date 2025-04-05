flake @ {
  inputs,
  self,
  lib,
  myLib,
  ...
}: let
  # Helper function for creating the system config for NixOS
  mkHost = hostname: {
    username ? throw "username must be set for ${hostname}",
    system ? throw "system must be set for ${hostname}",
    stateVersion ? throw "stateVersion must be set for ${hostname}",
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = flake // {inherit hostname username system stateVersion;};
      modules =
        myLib.slimports {
          paths = [
            ../core

            # Host machine
            ../hosts/${hostname}/config
            ../hosts/${hostname}/features.nix
            ../hosts/${hostname}/hardware-configuration.nix
            ../hosts/${hostname}/hostVars.nix

            # User
            ../users/${username}/system.nix
          ];
          optionalPaths = [
            ../users/${username}/config
            ../users/${username}/hosts/${hostname}.nix
          ];
        }
        ++ self.nixosModules.default;
    };
in
  mkHost
