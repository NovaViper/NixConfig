{ config, lib, pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
