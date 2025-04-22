{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  conf = {
    nixos =
      lib.recursiveUpdate {
        imports = with inputs; [agenix.nixosModules.default agenix-rekey.nixosModules.default];
        environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];
        services.pcscd.enable = lib.mkForce true;

        age.rekey = {
          #localStorageDir = myLib.secrets.getRekeyedPath "${config.networking.hostName}";
          hostPubkey = lib.mkDefault ../../../hosts/${config.networking.hostName}/ssh_host_ed25519_key.pub;
        };
      }
      conf.common;

    home = hm: let
      hm-config = hm.config;
    in
      lib.recursiveUpdate {
        imports = with inputs; [agenix.homeManagerModules.default agenix-rekey.homeManagerModules.default];

        # Add custom ssh key identity path specifically used for agenix
        age.identityPaths = lib.mkOptionDefault ["${hm-config.home.homeDirectory}/.ssh/nix-secret"];

        age.rekey = {
          #localStorageDir = myLib.secrets.getRekeyedPath "${hm-config.home.username}/${config.networking.hostName}";
          hostPubkey = lib.mkDefault ../../../users/${hm-config.home.username}/ssh.pub;
        };
      }
      conf.common;

    common = {
      age.rekey = {
        storageMode = "derivation";
        #storageMode = "local";
        agePlugins = with pkgs; [
          age-plugin-yubikey
          age-plugin-tpm
          age-plugin-ledger
          age-plugin-fido2-hmac
        ];

        # The path to the master identity used for decryption. See the option's description for more information.
        masterIdentities = myLib.secrets.mkSecretIdentities [
          "age-yubikey-identity-62397011.pub" # USB A
          "age-yubikey-identity-33fd18f7.pub" # USB C
        ];

        #extraEncryptionPubkeys = [];
      };
    };
  };
in
  conf.nixos
  // {
    home-manager.sharedModules = lib.singleton (hm: (conf.home hm));
  }
