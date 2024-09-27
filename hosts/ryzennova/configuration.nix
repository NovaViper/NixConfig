{
  config,
  pkgs,
  inputs,
  ...
}:
/*
     let
  vulkanDriverFiles = [
    "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json"
    "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
    "/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"
    "/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json"
    #"${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.x86_64.json"
    #"${config.hardware.nvidia.package.lib32}/share/vulkan/icd.d/nvidia_icd.i686.json"
    #"${pkgs.mesa.drivers}/share/vulkan/icd.d/intel_icd.x86_64.json"
  ];
in
*/
{
  imports = with inputs; [
    ### Hardware Modules
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-nvidia-nonprime
    hardware.nixosModules.common-pc-ssd

    ### Disko Config
    disko.nixosModules.disko
    ./disks.nix

    ### Hardware
    ../../modules/linux/hardware/rgb.nix
    ../../modules/linux/hardware/bluetooth.nix
    ../../modules/linux/hardware/qmk.nix
    ../../modules/linux/hardware/hardware-acceleration.nix

    ### Base Configs
    ../../modules/linux/systemd-boot.nix
    ../../modules/linux/quietboot.nix

    ### Service
    ../../modules/linux/services/sunshine.nix
    ../../modules/linux/services/tailscale.nix
    ../../modules/linux/services/flatpak.nix
    ../../modules/linux/services/printing.nix

    ### Applications
    ../../modules/linux/virtualization.nix
    ../../modules/linux/appimage.nix
    ../../modules/linux/waydroid.nix

    # Locale
    ../../modules/linux/locales/us-english.nix

    ### Import modules required for Desktop Environment
    ../../modules/linux/graphical
  ];

  # Make NixOS use the latest Linux Kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  hardware = {
    # Configure GPU
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  programs.nix-ld.libraries =
    [config.boot.kernelPackages.nvidiaPackages.beta]
    ++ (with pkgs; [
      nvidia-vaapi-driver
      #cudatoolkit
    ]);

  environment = {
    systemPackages = with pkgs; [nvitop];
    sessionVariables = {
      # Make libva use Nvidia
      #LIBVA_DRIVER_NAME = "nvidia";
      # Force VK to use Nvidia driver instead of NVK
      #VK_DRIVER_FILES = builtins.concatStringsSep ":" vulkanDriverFiles;
      # Enable hardware acceleration for Nvidia
      #VDPAU_DRIVER = "nvidia";
      # Enable new direct backend for NVIDIA-VAAPI-Driver
      #NVD_BACKEND = "direct";
      # Force GLX to use Nvidia
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Necessary to make Minecraft Wayland GLFW work with Wayland+Nvidia
      __GL_THREADED_OPTIMIZATIONS = "0";
      #GBM_BACKEND = "nvidia-drm";
      #__GL_GSYNC_ALLOWED = 1;
      #__GL_VRR_ALLOWED = 0;
      #VKD3D_CONFIG = "dxr11,dxr";
      #PROTON_ENABLE_NVAPI = 1;
      #DXVK_ENABLE_NVAPI = 1;
      #PROTON_ENABLE_NGX_UPDATER = 1;
      #PROTON_HIDE_NVIDIA_GPU = 0;
    };
  };
}
