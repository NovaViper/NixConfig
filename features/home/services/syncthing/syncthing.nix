{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfgFeat = osConfig.features;
in {
  services.syncthing.enable = true;

  services.syncthing.tray.enable =
    if (cfgFeat.desktop != null)
    then true
    else false;

  services.syncthing.extraOptions = [
    "--config=${config.xdg.configHome}/syncthing"
    "--data=${config.home.homeDirectory}/Sync"
  ];
}
