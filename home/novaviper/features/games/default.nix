{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./steam.nix ./minecraft.nix ./vr.nix];

  xdg.userDirs.extraConfig = {
    XDG_GAME_DIR = "${config.home.homeDirectory}/Games";
  };

  #home.packages = [pkgs.inputs.nix-gaming.wine-discord-ipc-bridge];
}
