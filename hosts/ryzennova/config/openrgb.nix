{
  config,
  lib,
  pkgs,
  ...
}:
{
  system.activationScripts.makeOpenRGBSettings = ''
    mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles
    cp ${./rgb-devices.json} /var/lib/OpenRGB/OpenRGB.json
  '';
}
