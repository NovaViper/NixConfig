{ config, lib, pkgs, ... }:

{
  programs.eza = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
    extraOptions = [ "--color=always" ];
  };
}
