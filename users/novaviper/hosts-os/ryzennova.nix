{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  imports = lib.singleton ./_shared.nix;
}
