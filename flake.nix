{
  # BASED ON https://github.com/Misterio77/nix-config/
  description = "My NixOS Configurations for multiple machines";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    hardware.url = "github:nixos/nixos-hardware";
    #impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "";
    };

    # Extras
    nix-colors.url = "github:misterio77/nix-colors";
    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    wallpapers = {
      url = "github:NovaViper/Wallpapers";
      flake = false;
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperml/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ## Hyperland
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    ##
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you pass to it, with each system as an argument
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });
    in {
      inherit lib;
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;
      #templates = import ./templates;

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs outputs; };

      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # Main desktop
        ryzennova = lib.nixosSystem {
          modules = [ ./hosts/ryzennova ];
          specialArgs = { inherit inputs outputs; };
        };
        # Personal laptop
        yoganova = lib.nixosSystem {
          modules = [ ./hosts/yoganova ];
          specialArgs = { inherit inputs outputs; };
        };
        nixosIso = lib.nixosSystem {
          modules = [ ./hosts/isoimage ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        # Desktops
        "novaviper@ryzennova" = lib.homeManagerConfiguration {
          modules = [ ./home/novaviper/ryzennova.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        # Laptops
        "novaviper@yoganova" = lib.homeManagerConfiguration {
          modules = [ ./home/novaviper/yoganova.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        # Portal minimum configuration
        "nixos@nixosIso" = lib.homeManagerConfiguration {
          modules = [ ./home/novaviper/generic.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    };
}
