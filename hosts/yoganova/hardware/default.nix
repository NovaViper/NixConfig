{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # This is needed for the IR emitter driver!
  ir-config =
    pkgs.writeText
    "pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver" ''
      device=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6:1.2-video-index0
      unit=7
      selector=6
      control0=1
      control1=3
      control2=2
      control3=0
      control4=0
      control5=0
      control6=0
      control7=0
      control8=0
    '';
in {
  imports = [
    ### Device Configs
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-hidpi
    ./hardware-configuration.nix
    ./disks.nix

    ### Hardware
    ../../common/optional/hardware/bluetooth.nix
    #../../common/optional/hardware/howdy.nix
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable powertop analysis tool
  powerManagement.powertop.enable = true;

  services = {
    # Enable Thunderbolt
    hardware.bolt.enable = true;

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

  # Apply configs
  system.activationScripts.copySysConfigs = ''
    mkdir -p /var/lib/linux-enable-ir-emitter

    if [ -z "$(ls -A /var/lib/linux-enable-ir-emitter)" ]; then
       cp ${ir-config} /var/lib/linux-enable-ir-emitter/pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver
    fi
  '';
}
