{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Make sure to include this so hardware acceloration actually works
  environment.sessionVariables.LD_LIBRARY_PATH = lib.mkBefore [ "/run/opengl-driver/lib" ];
  environment.systemPackages = with pkgs; [
    libva-utils
    clinfo
    mesa-demos
    vulkan-tools
    vulkan-loader
  ];

  # Enable OpenGL
  hardware.graphics =
    let
      extraPackages = with pkgs; [
        libva-utils
        libvdpau-va-gl
        vulkan-validation-layers
        vulkan-loader
      ];
    in
    {
      inherit extraPackages;
      enable = true;
      enable32Bit = true;
      extraPackages32 = extraPackages;
    };
}
