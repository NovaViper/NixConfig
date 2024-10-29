{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs; [
    ### Hardware Modules
    hardware.nixosModules.common-cpu-intel
    hardware.nixosModules.common-pc-laptop-ssd
    hardware.nixosModules.common-hidpi

    ### Disko Config
    disko.nixosModules.disko
    ./disks.nix
  ];

  modules =
    lib.utils.enable [
      ### Hardware
      "bluetooth"
      "hardware-accel"

      ### Base Configs
      "systemd-boot"
      "quietboot"

      ### Service
      "flatpak"
      "printing"
      "tailscale"

      ### Applications
      "appimage"
      "waydroid"
      "gaming"

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
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Enable powertop analysis tool
  powerManagement.powertop.enable = true;

  hardware.sensor.iio.enable = true;

  # Apply configs
  system.activationScripts.copySysConfigs = ''
    mkdir -p /var/lib/linux-enable-ir-emitter
    if [ -z "$(ls -A /var/lib/linux-enable-ir-emitter)" ]; then
       cp ${builtins.readFile ./config/ir-emitter-driver.txt} /var/lib/linux-enable-ir-emitter/pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver
    fi
  '';

  services = {
    # Enable Thunderbolt
    hardware.bolt.enable = true;

    # Enable Wacom touch drivers
    xserver.wacom.enable = true;

    # Fingerprint reader: login and unlock with fingerprint (if you add one with `fprintd-enroll`)
    # The driver doesn't work so far
    /*
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
    */

    # Set IR blaster device
    /*
      linux-enable-ir-emitter.device = "video2";

    # Configure Howdy
    howdy.settings = {
      video = {
        device_path = "/dev/video2";
        dark_threshold = 90;
      };
      # you may not need these
      core = {
        no_confirmation = true;
        ignore_closed_lid = true;
      };
    };
    */
  };
}
