{
  pkgs,
  modulesPath,
  lib,
  config,
  outputs,
  inputs,
  ...
}: {
  imports = [
    ../common/global
    ../common/users/nixos
    ../common/optional/desktop/kde/plasma6.nix
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];

  ### Special Variables
  variables.useKonsole = true;
  variables.desktop.displayManager = "wayland";

  # Theming with Stylix
  stylix = {
    image = "${pkgs.kdePackages.breeze}/share/wallpapers/Next/contents/images/1920x1200.png";
    polarity = "dark";
    cursor = {
      name = "breeze_cursors";
      size = 32;
    };
    fonts = rec {
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = sansSerif;
      monospace = {
        package = pkgs.hack-font;
        name = "Hack";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 11;
      };
    };
  };

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia and other drivers for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia" "modesetting" "fbdev"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
