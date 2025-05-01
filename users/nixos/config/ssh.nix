{ pkgs, ... }:
{
  programs.ssh.matchBlocks = {
    "yubikey-hosts" = {
      host = "github.com gitlab.com codeberg.org";
      identitiesOnly = true;
      extraOptions.PKCS11Provider = "${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
      #port = 22;
      #user = "git";
    };
  };
}
