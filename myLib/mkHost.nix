flake @ {
  inputs,
  self,
  lib,
  myLib,
  ...
}: let
  # Helper function for creating the system config for NixOS
  mkHost = hostname: {
    users,
    system ? throw "system must be set for ${hostname}",
    stateVersion ? throw "stateVersion must be set for ${hostname}",
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = flake // {inherit hostname system stateVersion;};
      modules =
        myLib.utils.concatImports {
          paths =
            [
              ../common/core

              ../hosts/${hostname}/configuration.nix
              ../hosts/${hostname}/hardware-configuration.nix
              ../hosts/${hostname}/hostVars.nix
            ]
            ++ lib.forEach users (u: ../users/${u}/common.nix)
            ++ lib.forEach users (u: lib.fileset.maybeMissing ../users/${u}/hosts/${hostname}.nix)
            ++ lib.forEach users (u: lib.fileset.maybeMissing ../users/${u}/config);
        }
        ++ self.nixosModules.default;
    };
in
  mkHost
