{ inputs, lib, pkgs, config, outputs, ... }:

{
  imports = [
    #inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ../features/cli
    ../features/nvim
    #../features/sops
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "novaviper";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/Documents/NixConfig";
      #FLAKE = "/etc/nixos/nixos-config";
      #CARGO_HOME = "${config.xdg.dataHome}/cargo";
    };
    /* persistence = {
         "/persist/home/novaviper" = {
           directories = [
             "Desktop"
             "Documents"
             "Downloads"
             "Music"
             "Pictures"
             "Videos"
             ".local/bin"
           ];
           allowOther = true;
         };
       };
    */
  };

  xdg = {
    enable = true;
    # Enable XDG
    userDirs.enable = true;
    userDirs.createDirectories = true;
    mimeApps.enable = true;

    # Import nixpkgs config into default path for nix shell commands
    configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
  };
}
