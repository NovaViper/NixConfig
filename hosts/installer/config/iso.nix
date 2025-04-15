{
  pkgs,
  inputs,
  ...
}: {
  imports = let
    nixpkgsModules = "${inputs.nixpkgs}/nixos/modules";
  in [
    #"${nixpkgsModules}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    "${nixpkgsModules}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  ];

  # Removed firefox and nano
  environment.defaultPackages = with pkgs; lib.mkForce [rsync gparted vim mesa-demos];

  # Enable autologin
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

  # faster compression, even if file is bigger
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  isoImage.edition = "plasma6";

  environment.systemPackages = with pkgs; [
    maliit-framework
    maliit-keyboard
  ];
}
