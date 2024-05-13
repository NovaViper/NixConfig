{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ### Device Configs
    ./hardware

    ### Base Configs
    ../common/base.nix
    ../common/boot/efi.nix
    ../common/boot/quietboot.nix

    ### Credentials
    ../common/credentials/gpg.nix
    ../common/credentials/ssh.nix

    ### Desktop Environment
    ../common/graphical/kde/plasma6.nix

    ### Service
    ../common/services/theme.nix
    ../common/services/syncthing.nix
    ../common/services/tailscale.nix
    ../common/services/flatpak.nix
    ../common/services/printing.nix

    ### Applications
    ../common/programs/appimage.nix
    ../common/programs/localsend.nix
    ../common/programs/gaming.nix
    ../common/programs/sunshine.nix

    ### Users
    ../common/users/novaviper
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
  system.stateVersion = "24.05"; # Did you read the comment?

  ### Special Variables
  variables.useVR = false;
  variables.useKonsole = true;
  variables.desktop.displayManager = "wayland";
  variables.machine.motherboard = "intel";
  variables.machine.buildType = "laptop";
  variables.machine.gpu = "intel";
  #variables.machine.lowSpec = true;
  ###
}
