{
  inputs,
  outputs,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = with inputs;
    [
      stylix.homeManagerModules.stylix
      plasma-manager.homeManagerModules.plasma-manager
      nixvim.homeManagerModules.nixvim
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      # Make sure flakes is enabled
      experimental-features = ["nix-command" "flakes"];
      # Don't spam about the git repo being dirty
      warn-dirty = false;
      # Optimize storage
      auto-optimise-store = true;

      substituters = [
        # Increase priority of NixOS cachix
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
  };

  xdg = {
    enable = true;
    # Import nixpkgs config into default path for nix shell commands
    configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
  };

  # Enable important programs
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Global variables for HomeManager
  home = {
    homeDirectory = mkDefault "/home/${config.home.username}";
    stateVersion = mkDefault "24.05";
    sessionPath = ["$HOME/.local/bin"];
  };
}
