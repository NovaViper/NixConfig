{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager.sharedModules = lib.singleton {
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
  };
}
