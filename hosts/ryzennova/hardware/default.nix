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
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  environment = {
    #systemPackages = with pkgs; [ gwe ];
    sessionVariables = {
      # Make libva use Nvidia
      LIBVA_DRIVER_NAME = "nvidia";
      # Force VK to use Nvidia driver instead of NVK
      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
      # Enable hardware acceleration for Nvidia
      VDPAU_DRIVER = "nvidia";
      # Enable new direct backend for NVIDIA-VAAPI-Driver
      NVD_BACKEND = "direct";
    };
  };

  system.activationScripts = lib.mkIf (config.services.hardware.openrgb.enable) {
    makeOpenRGBSettings = ''
      mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles

      cp ${configFile} /var/lib/OpenRGB/OpenRGB.json
    '';
  };
}
