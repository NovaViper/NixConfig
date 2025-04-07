{
  config,
  lib,
  pkgs,
  ...
}: let
  cfgFeat = config.features;
in {
  # services.syncthing = {
  #   user = lib.mkForce config.userVars.username;
  #   enable = true;
  #   dataDir = "${config.userVars.homeDirectory}/Sync";
  #   group = "users";
  #   configDir = "${config.userVars.homeDirectory}/.config/syncthing";
  #   openDefaultPorts = true;
  # };

  # environment.systemPackages = with pkgs; lib.mkIf (config.features.desktop != "none") [syncthingtray-minimal];

  networking.firewall.allowedTCPPorts = [22000];
  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [8384];

  hmUser = lib.singleton (hm: let
    hm-config = hm.config;
  in {
    services.syncthing.enable = true;

    services.syncthing.tray.enable =
      if (cfgFeat.desktop != "none")
      then true
      else false;

    services.syncthing.extraOptions = [
      "--config=${hm-config.xdg.configHome}/syncthing"
      "--data=${hm-config.home.homeDirectory}/Sync"
    ];
  });
}
