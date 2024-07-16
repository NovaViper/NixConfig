{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  nix = {
    package = pkgs.nixVersions.nix_2_22;
    settings = {
      # Make sure the root user and users in the wheel group are trusted
      trusted-users = ["root" "@wheel"];

      # Make sure flakes is enabled
      experimental-features = ["nix-command" "flakes"];

      # Don't spam about the git repo being dirty
      warn-dirty = false;

      # Enable more system features
      system-features = ["kvm" "big-parallel" "nixos-test"];

      # Disable global flake registry
      flake-registry = "";

      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # Force XDG Base Directory paths for Nix path
      use-xdg-base-directories = true;
    };

    # Perform nix store optimisation weekly to maintain low disk usage
    optimise = {
      automatic = true;
      dates = ["weekly"]; # Optional; allows customizing optimisation schedule
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      # Delete generations that are more than 14 days old
      options = "--delete-older-than 14d";
    };

    # Add each flake input as a registry and nix_path
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
}
