{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.yubikey-touch-detector.enable = lib.mkIf (config.features.desktop != null) true;

  # Allows PKCS11 Keys on Yubikey to be used for ssh authentication
  programs.ssh.agentPKCS11Whitelist = lib.getExe' pkgs.opensc "pkcs11.so";

  # Enable gpg smart cards
  hardware.gpgSmartcards.enable = true;

  # Enable PCSC-Lite daemon for Smartcard
  services.pcscd = {
    enable = true;
    plugins = with pkgs; [ccid libykneomgr];
  };

  # Install yubikey package to udev to give it usb access
  services.udev.packages = with pkgs; [yubikey-personalization];

  environment.systemPackages = with pkgs;
    [yubikey-personalization yubikey-manager yubico-piv-tool]
    ++ lib.optionals (config.features.desktop != null) [
      yubioath-flutter
    ];

  # Make Yubikeys work with gnupg
  home-manager.sharedModules = lib.singleton {
    programs.gpg.scdaemonSettings = {
      reader-port = "Yubico Yubi";
      disable-ccid = true;
    };
  };
}
