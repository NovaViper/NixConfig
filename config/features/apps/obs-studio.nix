{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Makes OBS Virtual Camera feature function
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
