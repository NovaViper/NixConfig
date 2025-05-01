{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Disabling these makes the ISO boot
  services.envfs.enable = lib.mkForce false;
  programs.nix-ld.enable = lib.mkForce false;
}
