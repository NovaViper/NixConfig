{
  lib,
  pkgs,
  hostname,
  stateVersion,
  system,
  inputs,
  ...
}: {
  imports = with inputs; [stylix.nixosModules.stylix];

  config = {
    # Setup primary variables for the systems
    networking.hostName = hostname;
    system.stateVersion = stateVersion;
    nixpkgs.hostPlatform = system;

    environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

    environment.systemPackages = with pkgs; [
      pciutils
      usbutils
      killall
      git
      git-crypt
      wget
      curl
      smartmontools
      openssl
      aha
      p7zip # For opening 7-zip files
      dmidecode # Get hardware information
      perl
      tree
      just
      pre-commit
    ];

    # Enable firmware updates on Linux
    services.fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"];
    };
  };
}
