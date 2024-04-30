{
  inputs,
  lib,
  ...
}: {
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
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 5 generations
      options = "--delete-older-than +5";
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };
}
