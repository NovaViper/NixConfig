{ config, lib, pkgs, ... }:

{
  imports = [ ./steam.nix ./minecraft.nix ./yuzu.nix ];

  xdg.userDirs.extraConfig = {
    XDG_GAME_DIR = "${config.home.homeDirectory}/Games";
  };

  #home.persistence = { "/persist/home/novaviper".directories = [ "Games" ]; };
}
