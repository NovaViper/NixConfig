{
  config,
  lib,
  pkgs,
  ...
}: {
  # Makes OBS Virtual Camera feature function
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];

  hmShared = lib.singleton {
    programs.obs-studio.enable = true;
    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
