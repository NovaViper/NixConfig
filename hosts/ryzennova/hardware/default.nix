{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  configFile = pkgs.writeText "OpenRGB.json" ''
    {
      "E131Devices": {
        "devices": [
          {
            "ip": "192.168.1.164",
            "name": "Desklight",
            "num_leds": 38,
            "rgb_order": 2,
            "start_channel": 1,
            "start_universe": 1,
            "type": 1
          }
        ]
      }
    }
  '';
  vulkanDriverFiles = [
    "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json"
    "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
    "/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"
    "/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json"
    #"${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.x86_64.json"
    #"${config.hardware.nvidia.package.lib32}/share/vulkan/icd.d/nvidia_icd.i686.json"
    #"${pkgs.mesa.drivers}/share/vulkan/icd.d/intel_icd.x86_64.json"
  ];
in {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disks.nix

    ### Hardware
    ../../common/optional/hardware/rgb.nix
    ../../common/optional/hardware/bluetooth.nix
    ../../common/optional/hardware/qmk.nix
    ../../common/optional/hardware/hardware-acceleration.nix
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware = {
    # Configure GPU
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;
      nvidiaSettings =
        if (config.variables.desktop.displayManager == "x11")
        then true
        else false;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  environment = {
    systemPackages = with pkgs; [nvitop];
    sessionVariables = {
      # Make libva use Nvidia
      LIBVA_DRIVER_NAME = "nvidia";
      # Force VK to use Nvidia driver instead of NVK
      #VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
      VK_DRIVER_FILES = builtins.concatStringsSep ":" vulkanDriverFiles;
      # Enable hardware acceleration for Nvidia
      #VDPAU_DRIVER = "nvidia";
      # Enable new direct backend for NVIDIA-VAAPI-Driver
      #NVD_BACKEND = "direct";
      # Force GLX to use Nvidia
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Necessary to make Minecraft Wayland GLFW work with Wayland+Nvidia
      __GL_THREADED_OPTIMIZATIONS = "0";
    };
  };

  system.activationScripts = lib.mkIf (config.services.hardware.openrgb.enable) {
    makeOpenRGBSettings = ''
      mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles

      cp ${configFile} /var/lib/OpenRGB/OpenRGB.json
    '';
  };
}
