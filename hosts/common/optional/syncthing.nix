{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    user = lib.mkForce config.variables.username;
    enable = true;
    dataDir = "/home/${config.services.syncthing.user}/Sync";
    group = "users";
    configDir = "/home/${config.services.syncthing.user}/.config/syncthing";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; [ syncthingtray-minimal ];
}
