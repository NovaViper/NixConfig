{ inputs, outputs, config, lib, pkgs, ... }:
with lib; {

  imports = with inputs;
    [
      stylix.homeManagerModules.stylix
      plasma-manager.homeManagerModules.plasma-manager
      nixvim.homeManagerModules.nixvim
    ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = import ./nixpkgs-config.nix;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
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
}
