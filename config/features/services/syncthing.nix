{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgFeat = config.features;
  hm-config = config.hm;
in
{
  networking.firewall = {
    interfaces."tailscale0".allowedTCPPorts = [ 8384 ];
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };

  # Most of the configuration is done with the Home-manager module
  hm.services.syncthing.enable = true;

  hm.services.syncthing.tray.enable = if (cfgFeat.desktop != null) then true else false;

  hm.services.syncthing.extraOptions = [
    "--config=${hm-config.xdg.configHome}/syncthing"
    "--data=${hm-config.home.homeDirectory}/Sync"
  ];
}
