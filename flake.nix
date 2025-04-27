{
  # BASED ON https://github.com/Misterio77/nix-config/
  description = "My NixOS Configurations for multiple machines";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    hardware.url = "github:nixos/nixos-hardware";
    systems.url = "github:nix-systems/default-linux";
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      # TODO: Waiting til https://github.com/Mic92/sops-nix/pull/781 is merged
      #url = "github:Mic92/sops-nix";
      url = "github:NovaViper/sops-nix/age-plugin";
      #url = "git+file:///home/novaviper/Documents/sops-nix?ref=age-plugin";
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
    menu = {
      url = "github:llakala/menu";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extras
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
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
      inputs.nixpkgs-unstable.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: https://github.com/NixOS/nixpkgs/issues/327982
    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wallpapers = {
      url = "github:NovaViper/Wallpapers";
      flake = false;
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/NovaViper/nix-secrets.git?ref=main&shallow=1";
      #url = "git+file:///home/novaviper/Documents/nix-secrets?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    # Nixpkgs PRs
    # TODO: https://github.com/NixOS/nixpkgs/pull/216245
    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";
  };

  # These are all just outputs for the flake
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    # Overlay my custom lib and home-manager lib onto the default nixpkgs lib
    myLib = import ./myLib {inherit inputs self;};

    # Flake evaluation tests and checks entrypoint
    # Available through 'nix flake check'
    checks = myLib.forEachSystem (pkgs: import ./checks {inherit inputs pkgs;});

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations =
      # Run mkHost for each nixosConfiguration, with key passed as hostname
      builtins.mapAttrs myLib.mkHost {
        # Main desktop
        ryzennova = {
          primaryUser = "novaviper";
          system = "x86_64-linux";
          stateVersion = "24.11";
        };

        # Personal laptop
        yoganova = {
          primaryUser = "novaviper";
          system = "x86_64-linux";
          stateVersion = "24.11";
        };

        # Live-image installer
        installer = {
          primaryUser = "nixos";
          system = "x86_64-linux";
          stateVersion = "25.05";
        };
      };
  in {
    # Just inherit everything we made in the let statement
    inherit myLib checks nixosConfigurations;

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules.default = myLib.slimports {paths = lib.singleton ./extra/nixosModules;};

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeModules.default = myLib.slimports {paths = lib.singleton ./extra/homeModules;};

    # Your custom packages and modifications, exported as overlays output
    overlays = import ./overlays {inherit self;};

    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = myLib.forEachSystem (pkgs: (lib.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ./pkgs/common;
    }));

    # Devshell for bootstrapping
    # Acessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = myLib.forEachSystem (pkgs: import ./shell.nix {inherit pkgs checks;});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = myLib.forEachSystem (pkgs: pkgs.alejandra);

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations =
      # Run mkHome for each homeConfiguration, with key passed as host
      builtins.mapAttrs myLib.mkHome {
        "novaviper@ryzennova" = {inherit nixosConfigurations;};
        "novaviper@yoganova" = {inherit nixosConfigurations;};
        "nixos@installer" = {inherit nixosConfigurations;};
      };
  };
}
