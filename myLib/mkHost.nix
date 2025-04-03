flake @ {
  inputs,
  self,
  lib,
  myLib,
  ...
}: let
  # Helper function for creating the system config for NixOS
  mkHost = hostname: {
    username ? "",
    system ? throw "system must be set for ${hostname}",
    stateVersion ? throw "stateVersion must be set for ${hostname}",
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = flake // {inherit hostname username system stateVersion;};
      modules = myLib.utils.concatImports {
        paths = [
          ../modules/core

          ../modules/features

          ../users/${username}/system.nix
          (lib.fileset.maybeMissing ../users/${username}/hosts/${hostname}.nix)
          (lib.fileset.maybeMissing ../users/${username}/config)

          ../hosts/${hostname}/configuration.nix
          ../hosts/${hostname}/hardware-configuration.nix
          #../hosts/${hostname}/hostVars.nix
        ];
      };
    };
in
  mkHost
