{
  config,
  lib,
  pkgs,
  username,
  ...
}:
lib.utilMods.mkModule config "syncthing" {
  services.syncthing = {
    user = lib.mkForce username;
    enable = true;
    dataDir = "/home/${username}/Sync";
    group = "users";
    configDir = "/home/${username}/.config/syncthing";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; lib.mkIf (lib.conds.runsDesktop config) [syncthingtray-minimal];
}
