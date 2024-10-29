{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "obs-studio" {
  # Makes OBS Virtual Camera feature function
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  hm.programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
