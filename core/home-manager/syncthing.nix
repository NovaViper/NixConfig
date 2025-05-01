{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  primaryUserOpts = opts: myLib.utils.getMainUserHMVar opts config;
in
{
  networking.firewall = lib.mkIf (primaryUserOpts "services.syncthing.enable") {
    interfaces."tailscale0".allowedTCPPorts = [ 8384 ];
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };
}
