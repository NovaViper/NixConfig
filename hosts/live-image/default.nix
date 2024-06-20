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
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    ../common/core

    ### Credentials
    ../common/optional/hardware-key.nix

    ### Desktop Environment
    ../common/optional/graphical/kde/plasma6.nix

    ### Users
    ../common/users/nixos
  ];

  ### Special Variables
  variables.useKonsole = true;
  variables.desktop.displayManager = "wayland";

  # Allow root login for SSH
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # Forcibly disable zfs for latest Linux firmware
  boot.supportedFilesystems.zfs = lib.mkForce false;

  hardware = {
    # Enable OpenGL
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    # Enable Nvidia drivers for desktop
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  # Load nvidia and other drivers for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia" "modesetting" "fbdev"];

  system.stateVersion = lib.mkForce "unstable";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
