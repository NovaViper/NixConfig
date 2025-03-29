{
  config,
  lib,
  pkgs,
  ...
}: {
  services.syncthing = {
    user = lib.mkForce config.userVars.username;
    enable = true;
    dataDir = "${config.userVars.homeDirectory}/Sync";
    group = "users";
    configDir = "${config.userVars.homeDirectory}/.config/syncthing";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; lib.mkIf (config.features.desktop != "none") [syncthingtray-minimal];
}
