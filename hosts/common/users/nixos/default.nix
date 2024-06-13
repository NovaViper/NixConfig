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
    # TODO: Until KDE Plasma 6.1 is released addessing NixOS/nixpkgs/issues/293964, add temporary password for live-image user.
    initialPassword = "nixos";
    initialHashedPassword = lib.mkForce null;
  };

  home-manager.users.nixos = import ../../../../home/nixos/image.nix;
}
