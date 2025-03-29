{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: {
  imports = let
    nixpkgsModules = "${inputs.nixpkgs}/nixos/modules";
  in
    [
      #"${nixpkgsModules}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
      "${nixpkgsModules}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
    ]
    ### Hardware
    ++ myLib.utils.importFromPath {
      path = ../../common/features/hardware;
      files = [
        "bluetooth"
        "hardware-acceleration"
        "yubikey"
      ];
    }
    ++ myLib.utils.importFromPath {
      path = ../../common/features;
      files = [
        ### Desktop Environment
        "desktop/plasma6"
      ];
    };
  # Removed firefox and nano
  environment.defaultPackages = with pkgs; lib.mkForce [rsync gparted vim mesa-demos];

  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  system.activationScripts.installerDesktop = let
    # Comes from documentation.nix when xserver and nixos.enable are true.
    manualDesktopFile = "/run/current-system/sw/share/applications/nixos-manual.desktop";

    homeDir = "/home/nixos/";
    desktopDir = homeDir + "Desktop/";
  in ''
    mkdir -p ${desktopDir}
    chown nixos ${homeDir} ${desktopDir}

    ln -sfT ${manualDesktopFile} ${desktopDir + "nixos-manual.desktop"}
    ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
    ln -sfT ${pkgs.calamares-nixos}/share/applications/io.calamares.calamares.desktop ${
      desktopDir + "io.calamares.calamares.desktop"
    }
  '';

  services.envfs.enable = lib.mkForce false;
  programs.nix-ld.enable = lib.mkForce false;

  # Make NixOS use the latest Linux Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Forcibly disable zfs for latest Linux firmware
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # faster compression, even if file is bigger
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  isoImage.edition = "plasma6";

  environment.systemPackages = with pkgs; [
    libnotify
    clamtk
    maliit-framework
    maliit-keyboard
  ];

  boot.initrd.systemd.emergencyAccess = true;

  # Enable Anti-virus
  services.clamav = {
    scanner.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
  };

  services.openssh = {
    ports = [22];
    # Allow root login for SSH
    settings.PermitRootLogin = lib.mkForce "yes";
  };

  # override installation-cd-base and enable wpa and sshd start at boot
  systemd.services.wpa_supplicant.wantedBy = lib.mkForce ["multi-user.target"];
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
}
