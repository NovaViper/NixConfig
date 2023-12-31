{ config, lib, pkgs, inputs, ... }:

let
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

    ../common/global
    ../common/users/novaviper

    #../common/optional/howdy.nix
    ../common/optional/desktop/kde.nix
    ../common/optional/syncthing.nix
    ../common/optional/tailscale.nix
    ../common/optional/localsend.nix
    ../common/optional/flatpak.nix
    ../common/optional/appimage.nix
    ../common/optional/gaming.nix
    ../common/optional/theme.nix
    ../common/optional/quietboot.nix
    ../common/optional/sunshine-server.nix
    #../common/optional/sunshine-client.nix
    ../common/optional/rgb.nix
    ../common/optional/libvirt.nix
    ../common/optional/qmk.nix
  ];

  networking.hostName = "ryzennova"; # Define your hostname.
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
  system.stateVersion = "23.11"; # Did you read the comment?

  ### Special Variables
  variables.useVR = true;
  variables.useKonsole = false;
  variables.machine.gpu = "nvidia";
  variables.desktop.useWayland = false;
  variables.machine.motherboard = "amd";
  variables.machine.buildType = "desktop";
  #variables.machine.lowSpec = false;
  ###

  hardware = {
    # Enable bluetooth
    bluetooth.enable = true;
    # Configure GPU
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;
      nvidiaSettings = config.services.xserver.enable;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment = {
    #systemPackages = with pkgs; [ gwe ];
    sessionVariables = { LIBVA_DRIVER_NAME = "nvidia"; };
  };

  system.activationScripts =
    lib.mkIf (config.services.hardware.openrgb.enable) {
      makeOpenRGBSettings = ''
        mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles

        cp ${configFile} /var/lib/OpenRGB/OpenRGB.json
      '';
    };
}
