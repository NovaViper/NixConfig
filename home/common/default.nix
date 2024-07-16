{
  inputs,
  lib,
  pkgs,
  config,
  self,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = with inputs;
    [
      plasma-manager.homeManagerModules.plasma-manager
      nixvim.homeManagerModules.nixvim
      nur.hmModules.nur
      ./xdg.nix
    ]
    ++ (builtins.attrValues self.homeManagerModules);

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      # Make sure flakes is enabled
      experimental-features = ["nix-command" "flakes"];
      # Don't spam about the git repo being dirty
      warn-dirty = false;
      # Optimize storage
      auto-optimise-store = true;
      # Force XDG Base Directory paths for Nix path
      use-xdg-base-directories = true;
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
  #systemd.user.startServices = "sd-switch";

  # Global variables for HomeManager
  home = {
    homeDirectory = mkDefault "/home/${config.home.username}";
    stateVersion = mkDefault "24.11";
    sessionPath = ["$HOME/.local/bin"];
  };
}
