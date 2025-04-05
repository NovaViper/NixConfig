{
  config,
  lib,
  pkgs,
  ...
}: {
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
}
