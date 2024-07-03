{
  config,
  lib,
  pkgs,
  ...
}: {
  variables.username = "nixos";

  users.users.${config.variables.username} = {
    shell = pkgs.zsh;
    packages = with pkgs; [home-manager];
  };

  home-manager.users.${config.variables.username} = import ../../../../home/${config.variables.username}/image.nix;

  # Make hardware clock use localtime.
  time.timeZone = lib.mkDefault "UTC";
}
