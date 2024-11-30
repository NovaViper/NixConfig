flake @ {
  inputs,
  self,
  lib,
  ...
}: let
  # Helper function for creating the system config for NixOS
  mkHost = hostname: {
    username,
    system,
    stateVersion ? lib.conds.defaultStateVersion,
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = flake // {inherit hostname username system stateVersion;};
      modules =
        if (lib.hasPrefix "installer" hostname)
        then [
          ../hosts/installer
        ]
        else
          lib.utils.concatImports {
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
