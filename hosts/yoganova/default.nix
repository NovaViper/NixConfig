{ config, lib, pkgs, inputs, ... }:
let
  # This is needed for the IR emitter driver!
  ir-config = pkgs.writeText
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
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-hidpi

    ./hardware-configuration.nix
    ./disks.nix

    ../common/global
    ../common/users/novaviper

    ../common/optional/howdy.nix
    ../common/optional/desktop/kde.nix
    ../common/optional/syncthing.nix
    ../common/optional/tailscale.nix
    ../common/optional/localsend.nix
    ../common/optional/flatpak.nix
    ../common/optional/appimage.nix
    ../common/optional/gaming.nix
    ../common/optional/theme.nix
    ../common/optional/quietboot.nix
    #../common/optional/sunshine-server.nix
    ../common/optional/sunshine-client.nix
    #../common/optional/rgb.nix
    #../common/optional/libvirt.nix
    ../common/optional/qmk.nix
  ];

  networking.hostName = "yoganova"; # Define your hostname.
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  ### Special Variables
  variables.useVR = false;
  variables.useKonsole = false;
  variables.machine.gpu = "intel";
  variables.desktop.useWayland = true;
  variables.machine.motherboard = "intel";
  variables.machine.buildType = "laptop";
  #variables.machine.lowSpec = true;
  ###

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  services = {
    # Fingerprint reader: login and unlock with fingerprint (if you add one with `fprintd-enroll`)
    # The driver doesn't work so far
    /* fprintd = {
         enable = true;
         tod = {
           enable = true;
           driver = pkgs.libfprint-2-tod1-goodix;
         };
       };
    */

    # Enable Thunderbolt
    hardware.bolt.enable = true;

    # Set IR blaster device
    linux-enable-ir-emitter.device = "video2";

    # Configure Howdy
    howdy.settings = {
      video = {
        device_path = "/dev/video2";
        dark_threshold = 90;
      };
      # you may not need these
      core.no_confirmation = true;
      /* rubberstamps = {
           enabled = true;
           stamp_rules = "nod 15s failsafe min_distance=5";
         };
      */
    };
  };

  # Apply configs
  system.activationScripts.copySysConfigs = ''
    mkdir -p /var/lib/linux-enable-ir-emitter

    if [ -z "$(ls -A /var/lib/linux-enable-ir-emitter)" ]; then
       cp ${ir-config} /var/lib/linux-enable-ir-emitter/pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver
    fi
  '';
}
