{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs;
    [
      ### Hardware Modules
      hardware.nixosModules.common-cpu-amd
      hardware.nixosModules.common-gpu-nvidia-nonprime
      hardware.nixosModules.common-pc-ssd

      ### Disko Config
      disko.nixosModules.disko
      ./disks.nix
    ]
    ### Hardware
    ++ myLib.utils.importFromPath {
      path = ../../common/features/hardware;
      files = [
        "bluetooth"
        "hardware-acceleration"
        "qmk"
        "rgb"
        "yubikey"
      ];
    }
    ### Service
    ++ myLib.utils.importFromPath {
      path = ../../common/features/services;
      files = [
        "appimage"
        "flatpak"
        "location"
        "printing"
        "sunshine"
        "syncthing"
        "tailscale"
        "wivrn"
      ];
    }
    ++ myLib.utils.importFromPath {
      path = ../../common/features;
      files = [
        ### Desktop Environment
        "desktop/plasma6"

        ### Applications
        "borg"
        "discord"
        "gaming"
        "obs-studio"
        "vm/virtualization"

        ### Boot
        "plymouth"
      ];
    };

  programs.localsend.enable = true;

  boot.kernelPackages = pkgs.pkgs.linuxPackages_6_12;

  # Enable proper Nvidia support for various packages
  nixpkgs.config.cudaSupport = lib.mkForce true;

  system.activationScripts.makeOpenRGBSettings = ''
    mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles
    cp ${./config/rgb-devices.json} /var/lib/OpenRGB/OpenRGB.json
  '';

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
    [config.hardware.nvidia.package]
    ++ (with pkgs; [
      nvidia-vaapi-driver
    ]);

  # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
  # Steam launch args: PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn_comp_ipc %command%
  services.wivrn.config.json = {
    # 50 Mb/s, default setting and seems to be the best for Beat Saber
    bitrate = 50 * 1000000;
    # 0.5x (50%) foveation scaling, don't need it super high because it makes latency higher (which is bad for Beat Saber)
    # Lower value means higher foveation
    scale = 0.5;
    encoders = [
      {
        encoder = "nvenc";
        codec = "h265";
        # 1.0 x 1.0 scaling, using the defaults
        width = 1.0;
        height = 1.0;
        offset_x = 0.0;
        offset_y = 0.0;
      }
    ];
    application = [pkgs.wlx-overlay-s];
  };

  environment = {
    systemPackages = with pkgs; [nvtopPackages.full];
    sessionVariables = {
      # Necessary to make Minecraft Wayland GLFW work with Wayland+Nvidia
      __GL_THREADED_OPTIMIZATIONS = "0";
      #PROTON_ENABLE_NVAPI = 1;
      #DXVK_ENABLE_NVAPI = 1;
    };
  };
}
