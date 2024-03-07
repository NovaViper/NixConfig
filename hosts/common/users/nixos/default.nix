{ config, lib, pkgs, ... }:

{
  variables.username = "nixos";

  users.users.nixos = {
    shell = pkgs.zsh;
    packages = with pkgs; [ home-manager ];
  };

  home-manager.users.nixos = import ../../../../home/nixos/image.nix;

}
