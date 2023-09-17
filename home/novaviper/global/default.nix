{ inputs, lib, pkgs, config, outputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; })
    colorschemeFromPicture nixWallpaperFromScheme;
in {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.nix-colors.homeManagerModule
    #../features/cli
    #../features/nvim
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

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    programs = {
      home-manager.enable = true;
      git.enable = true;
    };
  };

  home = {
    username = lib.mkDefault "novaviper";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
    #sessionVariables = { FLAKE = "$HOME/Documents/NixConfig"; };
    packages = with pkgs; [ firefox kate krita ];

    /* persistence = {
         "/persist/home/novaviper" = {
           directories =
             [ "Documents" "Downloads" "Pictures" "Videos" ".local/bin" ];
           allowOther = true;
         };
       };
    */
  };

  #colorscheme = lib.mkDefault colorSchemes.dracula;
}
