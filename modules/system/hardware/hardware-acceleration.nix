{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "hardware-accel" {
  # Make sure to include this so hardware acceloration actually works
  environment.sessionVariables.LD_LIBRARY_PATH = lib.mkBefore ["/run/opengl-driver/lib"];
  environment.systemPackages = with pkgs; [
    libva-utils
    clinfo
    glxinfo
    vulkan-tools
    vulkan-loader
  ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [libva-utils libvdpau-va-gl vulkan-validation-layers vulkan-loader] ++ lib.optionals config.modules.gaming.vr.enable [monado-vulkan-layers];
    extraPackages32 = with pkgs; [libva-utils libvdpau-va-gl vulkan-validation-layers vulkan-loader];
  };
}
