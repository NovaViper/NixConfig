{ config, lib, pkgs, ... }:

{
  imports = [ ./global.nix ];

  # Enable the KDE Plasma Desktop Environment.
  services.xserver = {
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  environment = {
    plasma5.excludePackages = with pkgs.libsForQt5; [ elisa ];
    systemPackages = with pkgs; [
      kate
      ktorrent
      krename
      kdiff3
      kfind
      clinfo # for kinfocenter for OpenCL page
      glxinfo # for kinfocenter for OpenGL EGL and GLX page
      vulkan-tools # for kinfocenter for Vulkan page
      libsForQt5.kdegraphics-thumbnailers
      libsForQt5.ffmpegthumbs
      ffmpegthumbnailer
      libsForQt5.qt5.qtimageformats
      qalculate-qt
      libsForQt5.packagekit-qt
    ];
  };
}
