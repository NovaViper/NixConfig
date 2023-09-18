{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ./global ./features/games ];

  colorscheme = inputs.nix-colors.colorSchemes.dracula;
}
