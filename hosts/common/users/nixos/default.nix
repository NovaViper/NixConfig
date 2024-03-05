{ config, lib, pkgs, ... }:

{
  variables.username = "nixos";

  environment.systemPackages = with pkgs; [ kitty ];

  #home-manager.users.nixos = import ../../../../home/nixos/generic.nix;

}
