{
  config,
  outputs,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"

    ### Import modules required for Desktop Environment
    ../../modules/linux/hardware/bluetooth.nix
    ../../modules/linux/graphical
  ];

  environment.systemPackages = with pkgs; [
    libnotify
    clamtk
  ];

  # Allow root login for SSH
  services.openssh.settings.PermitRootLogin = outputs.lib.mkForce "yes";

  # Forcibly disable zfs for latest Linux firmware
  boot.supportedFilesystems.zfs = outputs.lib.mkForce false;

  # Enable Anti-virus
  services.clamav = {
    scanner.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
  };

  services.envfs.enable = outputs.lib.mkForce false;
  programs.nix-ld.enable = outputs.lib.mkForce false;

  services.fwupd.enable = outputs.lib.mkForce false;

  # Make NixOS use the latest Linux Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = outputs.lib.mkForce "unstable";
}
