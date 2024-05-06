{
  inputs,
  lib,
  config,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  nix = {
    settings = {
      # Make sure the root user and users in the wheel group are trusted
      trusted-users = ["root" "@wheel"];

      # Make sure flakes is enabled
      experimental-features = ["nix-command" "flakes" "repl-flake"];

      # Don't spam about the git repo being dirty
      warn-dirty = false;

      # Optimize storage
      auto-optimise-store = true;

      # Enable more system features
      #system-features = [ "kvm" "big-parallel" "nixos-test" ];

      # Disable global flake registry
      flake-registry = "";

      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 5 generations
      options = "--delete-older-than +5";
    };

    # Add each flake input as a registry and nix_path
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
}
