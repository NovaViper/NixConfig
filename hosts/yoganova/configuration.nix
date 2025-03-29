{
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs;
    [
      ### Hardware Modules
      hardware.nixosModules.common-cpu-intel
      hardware.nixosModules.common-pc-laptop-ssd
      hardware.nixosModules.common-hidpi

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
        "yubikey" #"howdy"
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
        "syncthing"
        "tailscale"
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
        #"vm/waydroid"

        ### Boot
        "plymouth"
      ];
    };

  programs.localsend.enable = true;

  boot.kernelPackages = pkgs.pkgs.linuxPackages_6_12;

  # Enable powertop analysis tool
  powerManagement.powertop.enable = true;

  hardware.sensor.iio.enable = true;

  # Apply configs
  system.activationScripts.copySysConfigs = let
    folder = "/etc/linux-enable-ir-emitter";
  in ''
    mkdir -p ${folder}
    if [ -z "$(ls -A ${folder})" ]; then
       cp ${import ./config/ir-emitter-driver.nix {inherit pkgs;}} ${folder}/pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver
    fi
  '';

  services = {
    # Enable Thunderbolt
    hardware.bolt.enable = true;

    # Enable Wacom touch drivers
    xserver.wacom.enable = true;

    /*
    # Fingerprint reader: login and unlock with fingerprint (if you add one with `fprintd-enroll`)
    # The driver doesn't work so far
    fprintd = {
      enable = true;

      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    udev.packages = with pkgs; [
      libfprint-goodixtls-55x4
    ];
    */
    /*
    # Set IR blaster device
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
