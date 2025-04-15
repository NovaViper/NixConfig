{
  config,
  lib,
  pkgs,
  ...
}: {
  # Makes OBS Virtual Camera feature function
  # TODO: Maybe reformat this module
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];

  hmUser = lib.singleton {
    programs.obs-studio.enable = true;
    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
