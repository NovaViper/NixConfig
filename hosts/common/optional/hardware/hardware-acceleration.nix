{
  config,
  lib,
  pkgs,
  ...
}: {
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
    extraPackages = with pkgs; [libva-utils libvdpau-va-gl vulkan-validation-layers vulkan-loader];
    extraPackages32 = with pkgs; [libva-utils libvdpau-va-gl vulkan-validation-layers vulkan-loader];
  };
}
