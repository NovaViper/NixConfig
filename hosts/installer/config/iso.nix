{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports =
    let
      nixpkgsModules = "${inputs.nixpkgs}/nixos/modules";
    in
    lib.singleton "${nixpkgsModules}/installer/cd-dvd/installation-cd-graphical-calamares.nix";

  # faster compression, even if file is bigger
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  isoImage.edition = "plasma6";

  # Enable autologin
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  environment.systemPackages = with pkgs; [
    maliit-framework
    maliit-keyboard
    borgbackup
  ];

  # Removed firefox and nano
  environment.defaultPackages =
    with pkgs;
    lib.mkForce [
      rsync
      gparted
      vim
      mesa-demos
    ];

  environment.plasma6.excludePackages = [
    # Optional wallpapers that add 126 MiB to the graphical installer
    # closure. They will still need to be downloaded when installing a
    # Plasma system, though.
    pkgs.kdePackages.plasma-workspace-wallpapers
  ];

  # Avoid bundling an entire MariaDB installation on the ISO.
  programs.kde-pim.enable = false;

  system.activationScripts.installerDesktop =
    let
      # Comes from documentation.nix when xserver and nixos.enable are true.
      manualDesktopFile = "/run/current-system/sw/share/applications/nixos-manual.desktop";

      homeDir = "/home/nixos/";
      desktopDir = homeDir + "Desktop/";
    in
    ''
      mkdir -p ${desktopDir}
      chown nixos ${homeDir} ${desktopDir}

      ln -sfT ${manualDesktopFile} ${desktopDir + "nixos-manual.desktop"}
      ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
      ln -sfT ${pkgs.calamares-nixos}/share/applications/io.calamares.calamares.desktop ${
        desktopDir + "io.calamares.calamares.desktop"
      }
    '';
}
