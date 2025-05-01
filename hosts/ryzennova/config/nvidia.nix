{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable proper Nvidia support for various packages
  nixpkgs.config.cudaSupport = lib.mkForce true;

  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  programs.nix-ld.libraries =
    [ config.hardware.nvidia.package ]
    ++ (with pkgs; [
      nvidia-vaapi-driver
    ]);

  environment = {
    systemPackages = with pkgs; [ nvtopPackages.full ];
    sessionVariables = {
      # Necessary to make Minecraft Wayland GLFW work with Wayland+Nvidia
      __GL_THREADED_OPTIMIZATIONS = "0";
      #PROTON_ENABLE_NVAPI = 1;
      #DXVK_ENABLE_NVAPI = 1;
    };
  };
}
