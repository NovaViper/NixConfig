{
  config,
  lib,
  pkgs,
  ...
}: {
  variables.username = "nixos";

  users.users.nixos = {
    shell = pkgs.zsh;
    packages = with pkgs; [home-manager];
    # TODO: Until NixOS/nixpkgs/issues/293964 is fixed, add temporary password for live-image user.
    initialPassword = lib.mkForce "nixos";
    initialHashedPassword = lib.mkForce null;
  };

  home-manager.users.nixos = import ../../../../home/nixos/image.nix;
}
