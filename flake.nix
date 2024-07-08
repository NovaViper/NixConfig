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

    # Extras
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";
    nixvim = {
      url = "github:nix-community/nixvim";
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
  } @ inputs: let
    lib = nixpkgs.lib // home-manager.lib;

    # Supported systems for your flake packages, shell, etc are determined by the systems input.
    sys = import systems;
    # This is a function that generates an attribute by calling function you pass to it, with each system as an argument
    forAllSystems = function:
      lib.genAttrs sys (system: function pkgsFor.${system});
    # Supply nixpkgs for the forAllSystems function, applies overrides from the flake and allow unfree packages globally
    pkgsFor = lib.genAttrs sys (
      system:
        import nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
          config.allowUnfree = true;
        }
    );
    mkNixos = host: system:
      lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs self;};
        modules = [
          ./hosts/${host}
        ];
      };

    mkHome = host: user: system:
      lib.homeManagerConfiguration {
        pkgs = pkgsFor.${system};
        extraSpecialArgs = {inherit inputs self;};
        modules = [
          ./home/common/nixpkgs.nix
          ./home/${user}/${host}.nix
        ];
      };
  in {
    inherit lib;
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # Your custom packages and modifications, exported as overlays output
    overlays = import ./overlays {inherit self;};

    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (pkgs: import ./pkgs {inherit pkgs;});
    # Devshell for bootstrapping
    # Acessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = forAllSystems (pkgs: import ./shell.nix {inherit pkgs self;});
    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # Main desktop
      ryzennova = mkNixos "ryzennova" "x86_64-linux";
      # Personal laptop
      yoganova = mkNixos "yoganova" "x86_64-linux";
      # Live image
      live-image = mkNixos "live-image" "x86_64-linux";
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    /*
      homeConfigurations = {
      # Desktops
      "novaviper@ryzennova" = mkHome "ryzennova" "novaviper" "x86_64-linux";
    };
    */
  };
}
