{ lib, ... }:
{
  boot.initrd.systemd.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  services.envfs.enable = lib.mkForce false;

  #   boot.initrd.luks.devices = {
  #     cryptroot = {
  #       device = "/dev/disk/by-partlabel/luksRoot";
  #       tpm2 = true;
  #       allowDiscards = true;
  #     };
  #
  #     cryptswap = {
  #       device = "/dev/disk/by-partlabel/luksSwap";
  #       tpm2 = true;
  #       allowDiscards = true;
  #     };
  #   };
}
