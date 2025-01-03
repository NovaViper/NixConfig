{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkModule config "yubikey" {
  programs = {
    yubikey-touch-detector.enable = lib.mkIf config.modules.desktop.enable true;

    # Allows PKCS11 Keys on Yubikey to be used for ssh authentication
    ssh.agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";
  };

  # Enable gpg smart cards
  hardware.gpgSmartcards.enable = true;

  services = {
    # Enable PCSC-Lite daemon for Smartcard
    pcscd = {
      enable = true;
      plugins = with pkgs; [ccid libykneomgr];
    };
    # Install yubikey package to udev to give it usb access
    udev.packages = with pkgs; [yubikey-personalization];
  };

  environment.systemPackages = with pkgs;
    [yubikey-personalization yubikey-manager yubico-piv-tool]
    ++ lib.optionals config.modules.desktop.enable [
      yubioath-flutter
    ];

  home.shellAliases = {
    # Make gpg switch Yubikey
    gpg-switch-yubikey = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

    # Make gpg smartcard functionality work again
    fix-gpg-smartcard = "pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";
    # Load PKCS11 keys into ssh-agent
    load-pkcs-key = "ssh-add -s ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
    # Remove PKCS11 keys into ssh-agent
    remove-pkcs-key = "ssh-add -e ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
    # Make resident ssh keys import from Yubikey
    load-res-keys = "ssh-keygen -K";
  };

  # Make Yubikeys work with gnupg
  hm.programs.gpg.scdaemonSettings = {
    reader-port = "Yubico Yubi";
    disable-ccid = true;
  };
}
