{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  programs = {
    yubikey-touch-detector.enable = mkIf (config.services.xserver.enable) true;

    # Allows PKCS11 Keys on Yubikey to be used for ssh authentication
    ssh.agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";
  };

  # Enable gpg smart cards
  hardware.gpgSmartcards.enable = true;

  services = {
    # Enable PCSC-Lite daemon for Smartcard
    pcscd = {
      enable = true;
      plugins = [pkgs.libykneomgr];
    };
    # Install yubikey package to udev to give it usb access
    udev.packages = with pkgs; [yubikey-personalization];
  };

  environment.systemPackages = with pkgs;
    [yubikey-personalization yubikey-manager yubico-piv-tool]
    ++ lib.optionals (config.services.xserver.enable) [
      yubikey-personalization-gui
      yubikey-manager-qt
    ];
}
