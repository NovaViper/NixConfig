{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Disabling these makes the ISO boot
  programs.nix-ld.enable = lib.mkForce false;
}
