{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    dataDir = "/home/${config.services.syncthing.user}/Sync";
    group = "users";
    configDir = "/home/${config.services.syncthing.user}/.config/syncthing";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; [ syncthingtray-minimal ];
}
