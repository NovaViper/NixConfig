{
  config,
  lib,
  myLib,
  pkgs,
  username,
  ...
}:
myLib.utilMods.mkModule config "syncthing" {
  services.syncthing = {
    user = lib.mkForce username;
    enable = true;
    dataDir = "/home/${username}/Sync";
    group = "users";
    configDir = "/home/${username}/.config/syncthing";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; lib.mkIf (myLib.conds.runsDesktop config) [syncthingtray-minimal];
}
