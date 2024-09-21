{
  config,
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

    ### Hardware
    ../../modules/linux/hardware/bluetooth.nix
    #../../modules/linux/hardware/howdy.nix
    ../../modules/linux/hardware/hardware-acceleration.nix

    ### Base Configs
    ../../modules/linux/systemd-boot.nix
    ../../modules/linux/quietboot.nix

    ### Service
    ../../modules/linux/services/tailscale.nix
    ../../modules/linux/services/flatpak.nix
    ../../modules/linux/services/printing.nix

    ### Applications
    ../../modules/linux/appimage.nix
    #../../modules/linux/stylix.nix
    ../../modules/linux/waydroid.nix

    # Locale
    ../../modules/linux/locales/us-english.nix

    ### Import modules required for Desktop Environment
    ../../modules/linux/graphical
  ];

  # Make NixOS use the latest Linux Kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Enable powertop analysis tool
  powerManagement.powertop.enable = true;

  hardware.sensor.iio.enable = true;

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
