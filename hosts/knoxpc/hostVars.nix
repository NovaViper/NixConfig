{
  config,
  lib,
  pkgs,
  ...
}:
{
  hostVars = {
    configDirectory = "/etc/nixos";
    scalingFactor = 1;
  };
}
