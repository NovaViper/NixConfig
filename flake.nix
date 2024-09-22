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
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    hardware.url = "github:nixos/nixos-hardware";
    systems.url = "github:nix-systems/default-linux";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extras
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
  };

  # These are all just outputs for the flake
  outputs = {
    self,
    nixpkgs,
    home-manager,
    systems,
    ...
  } @ inputs: rec {
    lib = import ./lib {
      inherit inputs;
      inherit self;
      inherit (inputs.self) outputs;
    };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    #nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    #homeManagerModules = import ./modules/home-manager;

    # Your custom packages and modifications, exported as overlays output
    overlays = import ./overlays {inherit self;};

    checks = lib.forEachSystem (pkgs: import ./checks.nix {inherit inputs pkgs;});

    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = lib.forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    # Devshell for bootstrapping
    # Acessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = lib.forEachSystem (pkgs: import ./shell.nix {inherit pkgs checks;});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = lib.forEachSystem (pkgs: pkgs.alejandra);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # Main desktop
      ryzennova = lib.mkHost {
        system = "x86_64-linux";
        hostname = "ryzennova";
        users = ["novaviper"];
      };

      # Personal laptop
      yoganova = lib.mkHost {
        system = "x86_64-linux";
        hostname = "yoganova";
        users = ["novaviper"];
      };

      # ISO Image
      live-image = lib.mkHost {
        system = "x86_64-linux";
        hostname = "live-image";
        users = ["nixos"];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'

    homeConfigurations = {
      # Users
      novaviper = lib.mkUser {username = "novaviper";};
      nixos = lib.mkUser {username = "nixos";};

      # Machines
      "novaviper@ryzennova" = lib.mkUser {
        username = "novaviper";
        system = "x86_64-linux";
        hostname = "ryzennova";
      };

      "novaviper@yoganova" = lib.mkUser {
        username = "novaviper";
        system = "x86_64-linux";
        hostname = "yoganova";
      };

      "nixos@live-image" = lib.mkUser {
        username = "nixos";
        system = "x86_64-linux";
        hostname = "live-image";
      };
    };
  };
}
