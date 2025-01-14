{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs; [
    ### Hardware Modules
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-nvidia-nonprime
    hardware.nixosModules.common-pc-ssd

    ### Disko Config
    disko.nixosModules.disko
    ./disks.nix
  ];

  modules =
    myLib.utils.enable [
      ### Hardware
      "openrgb"
      "bluetooth"
      "qmk"
      "hardware-accel"

      ### Base Configs
      "systemd-boot"
      "quietboot"

      ### Service
      "flatpak"
      "printing"
      "sunshine-server"
      "tailscale"
      #"alvr"
      "wivrn"

      ### Applications
      "appimage"
      "waydroid"
      "virtualization"
      "obs-studio"

      ### Locale
      "us-english"

      ### Desktop Environment
      "plasma6"
    ]
    // {
      gaming = {
        enable = true;
        minecraft-server.enable = true;
      };
    };

  # Make NixOS use the latest Linux Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
