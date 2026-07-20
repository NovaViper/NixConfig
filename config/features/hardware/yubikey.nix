{
  config,
  lib,
  pkgs,
  ...
}:
let
  pkcs11 = "${pkgs.opensc}/lib/opensc-pkcs11.so";
in
{
  programs.yubikey-touch-detector.enable = lib.mkIf (config.features.desktop.type != null) true;

  # Allows PKCS11 Keys on Yubikey to be used for ssh authentication
  programs.ssh.agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";

  # Enable gpg smart cards
  hardware.gpgSmartcards.enable = true;

  # Enable PCSC-Lite daemon for Smartcard
  services.pcscd = {
    enable = true;
    plugins = with pkgs; [
      ccid
      libykneomgr
    ];
  };

  # Install yubikey package to udev to give it usb access
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  environment.systemPackages =
    with pkgs;
    [
      load-resident-key # Custom script for loading resident keys
      yubikey-personalization
      yubikey-manager
      yubico-piv-tool
    ]
    ++ lib.optionals (config.features.desktop.type != null) [
      yubioath-flutter
    ];

  # Make Yubikeys work with gnupg
  hm.programs.gpg.scdaemonSettings = {
    reader-port = "Yubico Yubi";
    disable-ccid = true;
  };

  hm.home.shellAliases = {
    # Make gpg switch Yubikey
    switch-yubikey-gpg = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

    # Make gpg smartcard functionality work again
    reload-gpg-smartcard = "pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";

    # Load PKCS11/PIV keys into ssh-agent
    load-piv-keys = "ssh-add -s ${pkcs11}";

    # Remove PKCS11 keys into ssh-agent
    remove-piv-keys = "ssh-add -e ${pkcs11}";
  };
}
