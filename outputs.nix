{ self, nixpkgs, ... }@inputs:
let
  inherit (nixpkgs) lib;

  # Overlay my custom lib and home-manager lib onto the default nixpkgs lib
  myLib = import ./myLib { inherit inputs self; };

  # Flake evaluation tests and checks entrypoint
  # Available through 'nix flake check'
  checks = myLib.forEachSystem (pkgs: import ./checks { inherit inputs pkgs; });

  # NixOS configuration entrypoint
  # Available through 'nixos-rebuild --flake .#your-hostname'
  nixosConfigurations =
    # Run mkHost for each nixosConfiguration, with key passed as hostname
    builtins.mapAttrs myLib.mkHost {
      # Main desktop
      ryzennova = {
        username = "novaviper";
        system = "x86_64-linux";
        stateVersion = "25.05";
        profiles = lib.singleton "home-pc";
      };

      # Personal laptop
      yoganova = {
        username = "novaviper";
        system = "x86_64-linux";
        stateVersion = "25.05";
        profiles = lib.singleton "home-pc";
      };

      # Homelab
      knoxpc = {
        username = "novaviper";
        system = "x86_64-linux";
        stateVersion = "25.05";
      };

      # Live-image installer
      installer = {
        username = "nixos";
        system = "x86_64-linux";
        stateVersion = "25.05";
      };
    };
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
  # Acessible through 'nix build', 'nix shell', etc
  packages = myLib.forEachSystem (
    pkgs:
    (lib.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ./pkgs/common;
    })
  );

  # Devshell for bootstrapping
  # Acessible through 'nix develop' or 'nix-shell' (legacy)
  devShells = myLib.forEachSystem (pkgs: import ./shell.nix { inherit pkgs checks; });

  # Formatter for your nix files, available through 'nix fmt'
  # Other options beside 'alejandra' include 'nixpkgs-fmt'
  formatter = myLib.forEachSystem (pkgs: pkgs.nixfmt-tree);

  # Standalone home-manager configuration entrypoint
  # Available through 'home-manager --flake .#your-username@your-hostname'
  homeConfigurations =
    # Run mkHome for each homeConfiguration, with key passed as host
    builtins.mapAttrs myLib.mkHome {
      "novaviper@ryzennova" = { inherit nixosConfigurations; };
      "novaviper@yoganova" = { inherit nixosConfigurations; };
      "novaviper@knoxpc" = { inherit nixosConfigurations; };
      "nixos@installer" = { inherit nixosConfigurations; };
    };
}
