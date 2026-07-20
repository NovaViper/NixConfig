{
  config,
  pkgs,
  self,
  lib,
  myLib,
  inputs,
  stateVersion,
  system,
  ...
}:
{
  # Setup primary variables for the systems
  system.stateVersion = stateVersion;
  nixpkgs.hostPlatform = system;

  # Config Nixpkgs
  nixpkgs = {
    overlays = builtins.attrValues self.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  documentation.nixos.enable = false; # Apparently speeds up rebuild time

  # Run unpatched dynamic binaries on NixOS
  programs.nix-ld.enable = true;

  nix = {
    # Makes `nix run` commands use unfree
    registry = lib.mkForce {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-stable.flake = inputs.nixpkgs-stable;

      # Allow running unfree packages with nix3 commands via `nix run unfree#steam`
      unfree.flake = pkgs.callPackage myLib.mkUnfreeNixpkgs { path = inputs.nixpkgs; };
      unfree-stable.flake = pkgs.callPackage myLib.mkUnfreeNixpkgs { path = inputs.nixpkgs-stable; };
    };

    # Force latest nix version
    package = pkgs.nixVersions.latest;

    # for Nix path
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Perform nix store optimisation weekly to maintain low disk usage
    optimise = {
      automatic = true;
      dates = [ "daily" ]; # Optional; allows customizing optimisation schedule
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "daily";
      # Delete generations that are more than 7 days old
      options = "--delete-older-than 7d";
    };

    settings = {
      # Make sure flakes is enabled
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # No warnings if git isn't pushed
      warn-dirty = false;

      # Force XDG Base Directory paths
      use-xdg-base-directories = true;

      # Make root and any user in the wheel group trusted
      trusted-users = [ "@wheel" ];

      substituters = [
        "https://cache.nixos-cuda.org"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];

      # Make nix automatically optimise the store, helps with disk space
      auto-optimise-store = true;

      # Reasonable defaults, see https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB
      fallback = true; # If binary cache fails, it's okay
      keep-going = true; # If a derivation fails, build the others. We'll fix the failed one later
    };
  };

  # Enable nix-index-database for faster searching of packages
  hm.programs.nix-index-database.comma.enable = true;

  # Enable nix-your-shell for automatically generating shell.nix files for
  # projects
  hm.programs.nix-your-shell.enable = true;

  # Much nicer Nix related toolset for nix development
  hm.home.packages =
    with pkgs;
    lib.optionals (config.features.development.enable) [
      nh # Nice wrapper for NixOS and HM
      nixfmt # Nix formatter
      nix-output-monitor # Monitor Nix compilation
      nvd # Nix/NixOS package version diff tool
      nixpkgs-review # Review nixpkgs
      nurl # Automated prefetch tool for
      nix-init # Automatically create nix packages from URLs
      nix-inspect # View nix configurations
      nil # Nix LSP
      nixd # Another Nix LSP
      deadnix # Deadcode finder for NIx
      statix # Anti-pattern detector
      hydra-check
    ];
}
