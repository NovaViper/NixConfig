{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../standard.nix];

  variables.username = "nixos";

  users.users.${config.variables.username} = {
    shell = pkgs.zsh;
  };

  home-manager.users.${config.variables.username} = import ../../../../home/${config.variables.username}/image.nix;

  # Not needed for live-images
  time.hardwareClockInLocalTime = false;
}
