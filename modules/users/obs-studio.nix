{
  outputs,
  config,
  osConfig,
  pkgs,
  ...
}:
outputs.lib.mkDesktopModule config "obs-studio" {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };

  # Makes OBS Virtual Camera feature function
  nixos.boot.extraModulePackages = with osConfig.boot.kernelPackages; [v4l2loopback];
}
