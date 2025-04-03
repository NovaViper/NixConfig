{
  config,
  pkgs,
  self,
  lib,
  myLib,
  inputs,
  ...
}: {
  # Config Nixpkgs
  nixpkgs = {
    overlays = builtins.attrValues self.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  environment.variables.NIX_SSHOPTS = "-t";

  documentation.nixos.enable = false; # Apparently speeds up rebuild time

  nix = {
    # Makes `nix run` commands use unfree
    registry = lib.mkForce {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-stable.flake = inputs.nixpkgs-stable;

      # Allow running unfree packages with nix3 commands via `nix run unfree#steam`
      unfree.flake = pkgs.callPackage myLib.mkUnfreeNixpkgs {path = inputs.nixpkgs;};
      unfree-stable.flake = pkgs.callPackage myLib.mkUnfreeNixpkgs {path = inputs.nixpkgs-stable;};
    };

    # Force latest nix version
    package = pkgs.nixVersions.latest;

    # Perform nix store optimisation weekly to maintain low disk usage
    optimise = {
      automatic = true;
      dates = ["daily"]; # Optional; allows customizing optimisation schedule
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "daily";
      # Delete generations that are more than 4 days old
      options = "--delete-older-than 4d";
    };

    settings = {
      # Make sure flakes is enabled
      experimental-features = ["nix-command" "flakes"];

      # No warnings if git isn't pushed
      warn-dirty = false;

      # Force XDG Base Directory paths
      use-xdg-base-directories = true;

      # for Nix path
      nix-path = ["nixpkgs=${pkgs.path}"];

      # Make root and any user in the wheel group trusted
      trusted-users = ["@wheel"];

      substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];

      # Make nix automatically optimise the store, helps with disk space
      auto-optimise-store = true;

      # Reasonable defaults, see https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB
      fallback = true; # If binary cache fails, it's okay
      keep-going = true; # If a derivation fails, build the others. We'll fix the failed one later
    };
  };
}
