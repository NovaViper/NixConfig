{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    #configDir = "$HOME/.config/syncthing";
    openDefaultPorts = true;
  };
}
