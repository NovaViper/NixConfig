{
  # BASED ON https://github.com/Misterio77/nix-config/
  description = "My NixOS Configurations for multiple machines";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos-cuda.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    # nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #######

    # Extras
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Access the nightly builds
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    #######

    # Personal Repos
    wallpapers = {
      url = "git+https://codeberg.org/NovaViper/Wallpapers";
      flake = false;
    };
    nix-secrets = {
      url = "git+ssh://git@codeberg.org/NovaViper/nix-secrets.git?ref=main&shallow=1";
      #url = "git+file:///home/novaviper/Documents/Projects/nix-secrets?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    novavim = {
      url = "git+https://codeberg.org/NovaViper/novavim";
      #url = "git+file:///home/novaviper/Documents/Projects/novavim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #######

    # Nixpkgs PRs
    #######
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      # Overlay my custom lib and home-manager lib onto the default nixpkgs lib
      myLib = import ./myLib { inherit inputs self; };

      # Flake evaluation tests and checks entrypoint
      # Available through 'nix flake check'
      checks = myLib.forAllSystems (pkgs: import ./checks { inherit self pkgs; });

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      hosts = {
        # Main desktop
        ryzennova = {
          username = "novaviper";
          system = "x86_64-linux";
          roles = lib.singleton "home-pc";
        };

        # Personal laptop
        framenova = {
          username = "novaviper";
          system = "x86_64-linux";
          roles = lib.singleton "home-pc";
        };

        # Homelab
        knoxpc = {
          username = "novaviper";
          system = "x86_64-linux";
        };

        # Live-image installer
        installer = {
          username = "nixos";
          system = "x86_64-linux";
        };
      };
      # Run mkHost for each nixosConfiguration, with key passed as hostname
      nixosConfigurations = builtins.mapAttrs (myLib.mkHost hosts) hosts;
    in
    {
      # Just inherit everything we made in the let statement
      inherit myLib checks nixosConfigurations;

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules.default = myLib.slimports { paths = lib.singleton ./extra/nixosModules; };

      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeModules.default = myLib.slimports { paths = lib.singleton ./extra/homeModules; };

      # Your custom packages and modifications, exported as overlays output
      overlays = import ./overlays { inherit self; };

      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = myLib.forAllSystems (
        pkgs:
        myLib.utils.flattenPackages (
          lib.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage newScope;
            directory = ./pkgs;
          }
        )
      );

      # Devshell for bootstrapping
      # Accessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = myLib.forAllSystems (pkgs: import ./shell.nix { inherit pkgs checks; });

      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = myLib.forAllSystems (pkgs: pkgs.nixfmt-tree);

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations =
        # Run mkHome for each homeConfiguration, with key passed as host
        builtins.mapAttrs myLib.mkHome {
          "novaviper@ryzennova" = { inherit nixosConfigurations; };
          "novaviper@framenova" = { inherit nixosConfigurations; };
          "novaviper@knoxpc" = { inherit nixosConfigurations; };
          "nixos@installer" = { inherit nixosConfigurations; };
        };

    };
}
