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
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      joypixels.acceptLicense = true;
    };
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
    stateVersion = lib.mkDefault "23.05";
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

  # Enable XDG
  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
    mimeApps.enable = true;
  };
}
