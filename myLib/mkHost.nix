flake @ {
  inputs,
  self,
  lib,
  myLib,
  ...
}: let
  # Helper function for creating the system config for NixOS
  mkHost = hostname: {
    users ? throw "users must be set for ${hostname}",
    system ? throw "system must be set for ${hostname}",
    stateVersion ? throw "stateVersion must be set for ${hostname}",
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = flake // {inherit hostname users system stateVersion;};
      modules =
        myLib.slimports {
          paths = lib.flatten [
            ../core

            # Host machine
            ../hosts/${hostname}/config
            ../hosts/${hostname}/features.nix
            ../hosts/${hostname}/hardware-configuration.nix
            ../hosts/${hostname}/hostVars.nix

            # User
            (map (user: ../users/${user}/system.nix) users)
          ];

          optionalPaths = lib.flatten (map (user: [
              #../users/${user}/config
              ../users/${user}/hosts/${hostname}.nix
            ])
            users);
        }
        ++ self.nixosModules.default;
    };
in
  mkHost
