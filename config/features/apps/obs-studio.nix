{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Makes OBS Virtual Camera feature function
  # TODO: Maybe reformat this module
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  hm.programs.obs-studio.enable = true;
  hm.programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-vkcapture
    obs-pipewire-audio-capture
  ];
}
