# This file should be included when using Home-Manager standalone
{
  lib,
  inputs,
  self,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      flake-registry = ""; # Disable global flake registry
      # Force XDG Base Directory paths for Nix path
      use-xdg-base-directories = true;
    };
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
  };

  home.sessionVariables = {
    NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
  };

  nixpkgs = {
    overlays = builtins.attrValues self.overlays;
    config = import ./nixpkgs-config.nix;
  };
}
