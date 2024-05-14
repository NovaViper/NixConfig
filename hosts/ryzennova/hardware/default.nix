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
    ./hardware-configuration.nix
    ./disks.nix

    ### Hardware
    ../../common/hardware/rgb.nix
    ../../common/hardware/bluetooth.nix
    ../../common/hardware/qmk.nix
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

  services.xserver.videoDrivers = ["nvidia"];

  environment = {
    #systemPackages = with pkgs; [ gwe ];
    sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  };

  system.activationScripts = lib.mkIf (config.services.hardware.openrgb.enable) {
    makeOpenRGBSettings = ''
      mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles

      cp ${configFile} /var/lib/OpenRGB/OpenRGB.json
    '';
  };
}