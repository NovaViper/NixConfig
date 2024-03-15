{ config, lib, pkgs, ... }:

{
  programs.eza = {
    enable = true;
    git = true;
    icons = true;
    extraOptions =
      [ "--color=always" "--group-directories-first" "--classify" ];
  };
}
