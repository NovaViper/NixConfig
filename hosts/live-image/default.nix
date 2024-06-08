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
    ../common/base.nix

    ### Credentials
    ../common/credentials/hardware-key.nix
    ../common/credentials/gpg.nix
    ../common/credentials/ssh.nix

    ### Desktop Environment
    ../common/graphical/kde/plasma6.nix

    ### Users
    ../common/users/nixos
  ];

  ### Special Variables
  variables.useKonsole = true;
  variables.desktop.displayManager = "wayland";

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
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
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # kde power settings do not turn off screen
  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  # Load nvidia and other drivers for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia" "modesetting" "fbdev"];

  system.stateVersion = lib.mkForce "unstable";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
