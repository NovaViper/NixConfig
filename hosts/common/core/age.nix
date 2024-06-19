{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  agePath = path: ../../../secrets/${path};
in {
  imports = with inputs; [agenix.nixosModules.default];

  environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

  age = {
    ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${pkgs.age}/bin/age";
    identityPaths = [
      (agePath "identities/age-yubikey-identity-a38cb00a-usba.txt")
      #(agePath "identities/age-yubikey-identity-ID-INTERFACE.txt")
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };
}
