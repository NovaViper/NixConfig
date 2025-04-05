{
  config,
  lib,
  pkgs,
  ...
}: let
  cfgFeat = config.features;
  hm-config = config.hm;
in {
  services.syncthing = {
    user = lib.mkForce config.userVars.username;
    enable = true;
    dataDir = "${config.userVars.homeDirectory}/Sync";
    group = "users";
    configDir = "${config.userVars.homeDirectory}/.config/syncthing";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; lib.mkIf (config.features.desktop != "none") [syncthingtray-minimal];

  # TODO Upcoming changes
  /*
    networking.firewall.allowedTCPPorts = [22000];
  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [8384];

  hm.services.syncthing.enable = true;

  hm.services.syncthing.tray.enable =
    if (cfgFeat.desktop != "none")
    then true
    else false;

  hm.services.syncthing.extraOptions = [
    "--config=${hm-config.xdg.configHome}/syncthing"
    "--data=${config.userVars.homeDirectory}/Sync"
  ];
  */
}
