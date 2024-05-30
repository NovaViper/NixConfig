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
    ../common/services/syncthing.nix
    ../common/services/tailscale.nix
    ../common/services/flatpak.nix
    ../common/services/printing.nix

    ### Applications
    ../common/programs/appimage.nix
    ../common/programs/localsend.nix
    ../common/programs/gaming.nix
    ../common/programs/sunshine.nix
    ../common/programs/stylix.nix

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
  system.stateVersion = "24.11"; # Did you read the comment?

  ### Special Variables
  variables.useVR = false;
  variables.useKonsole = true;
  variables.desktop.displayManager = "wayland";
  variables.machine.motherboard = "intel";
  variables.machine.buildType = "laptop";
  variables.machine.gpu = "intel";
  #variables.machine.lowSpec = true;
  ###

  stylix = {
    autoEnable = true;
    homeManagerIntegration.autoImport = false;
    image = "${inputs.wallpapers}/purple-mountains-ai.png";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    override = {
      base00 = "282A36"; # Previously: "282936"
      #base01 = "3A3C4E"; # Unchanged
      base02 = "44475A"; # Previously: "4d4f68"
      base03 = "6272A4"; # Previously: "626483"
      #base04 = "62D6E8"; # Unchanged
      base05 = "F8F8F2"; # Previously: "e9e9f4"
      #base06 = "F1F2F8"; # Unchanged
      #base07 = "F7F7FB"; # Unchanged
      base08 = "FF5555"; # Previously: "ea51b2"
      base09 = "FFB86C"; # Previously: "B45BCF"
      base0A = "F1FA8C"; # Previously: "00f769"
      base0B = "50FA7B"; # Previously: "ebff87"
      base0C = "8BE9FD"; # Previously: "a1efe4"
      base0D = "BD93F9"; # Previously: "62d6e8"
      base0E = "FF79C6"; # Previously: "b45bcf"
      #base0F = "00F769"; # Unchanged
    };
    polarity = "dark";
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
    fonts = rec {
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "NotoSans Nerd Font";
      };
      serif = sansSerif;
      monospace = {
        package = pkgs.nerdfonts;
        name = "0xProto Nerd Font Mono";
      };
      emoji = {
        package = pkgs.nerdfonts;
        name = "0xProto Nerd Font Mono";
      };
      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 11;
      };
    };
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 1.0;
      terminal = 1.0;
    };
  };
}
