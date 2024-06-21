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
    ../common/iso

    ### Credentials
    ../common/optional/hardware-key.nix

    ### Desktop Environment
    ../common/optional/graphical/kde/plasma6.nix

    ### Users
    ../common/users/nixos
  ];

  environment.systemPackages = with pkgs; [
    #Notifications
    libnotify
  ];

  ### Special Variables
  variables.useKonsole = true;
  variables.desktop.displayManager = "wayland";

  # Allow root login for SSH
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # Forcibly disable zfs for latest Linux firmware
  boot.supportedFilesystems.zfs = lib.mkForce false;

  hardware.bluetooth.enable = true;

  system.stateVersion = lib.mkForce "unstable";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
