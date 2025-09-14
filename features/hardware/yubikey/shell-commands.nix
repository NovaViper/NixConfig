{
  config,
  lib,
  pkgs,
  ...
}:
let
  pkcs11 = "${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
in
{
  hm.home.shellAliases = {
    # Make gpg switch Yubikey
    switch-yubikey-gpg = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

    # Make gpg smartcard functionality work again
    reload-gpg-smartcard = "pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";

    # Load PKCS11/PIV keys into ssh-agent
    load-piv-keys = "ssh-add -s ${pkcs11}";

    # Remove PKCS11 keys into ssh-agent
    remove-piv-keys = "ssh-add -e ${pkcs11}";

    # Make resident ssh keys import from Yubikey
    load-resident-keys = "cd ~/.ssh && ssh-keygen -K && cd -";
  };
}
