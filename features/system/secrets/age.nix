{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  identities = lib.mapAttrsToList (user: hmConfig: hmConfig.userVars.userIdentityPaths) config.home-manager.users;
  flattenId = lib.unique (lib.flatten identities);
  idList = lib.toList (builtins.toString identities);
  #idList = lib.toList identities;
in {
  imports = with inputs; [agenix.nixosModules.default agenix-rekey.nixosModules.default];

  environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];
  #age.identityPaths = lib.mkOptionDefault flattenId;

  services.pcscd.enable = lib.mkForce true;

  age.rekey = {
    #storageMode = "derivation";
    #
    storageMode = "local";
    localStorageDir = ../../../secrets/rekeyed/${config.networking.hostName};
    hostPubkey = ../../../hosts/${config.networking.hostName}/ssh_host_ed25519_key.pub;
    /*
      agePlugins = with pkgs; [
      age-plugin-yubikey
      age-plugin-tpm
      age-plugin-ledger
    ];
    */

    # The path to the master identity used for decryption. See the option's description for more information.
    masterIdentities = myLib.secrets.mkSecretIdentities [
      "age-yubikey-identity-4416b57b.pub" # USB A
      "age-yubikey-identity-2c8a1039.pub" # USB C
    ];

    #extraEncryptionPubkeys = [];
  };

  home-manager.sharedModules = lib.singleton (hm: {
    imports = with inputs; [agenix.homeManagerModules.default agenix-rekey.homeManagerModules.default];

    age.identityPaths = myLib.secrets.mkSecretIdentities [
      "age-yubikey-identity-4416b57b.pub"
    ];

    age.rekey = {
      #storageMode = "derivation";
      #
      storageMode = "local";
      localStorageDir = ../../../secrets/rekeyed/${hm.config.home.username}/${config.networking.hostName};
      hostPubkey = ../../../hosts/${config.networking.hostName}/ssh_host_ed25519_key.pub;
      /*
        agePlugins = with pkgs; [
        age-plugin-yubikey
        age-plugin-tpm
        age-plugin-ledger
      ];
      */

      # The path to the master identity used for decryption. See the option's description for more information.
      masterIdentities = myLib.secrets.mkSecretIdentities [
        "age-yubikey-identity-4416b57b.pub"
      ];

      #extraEncryptionPubkeys = [];
    };
  });
}
