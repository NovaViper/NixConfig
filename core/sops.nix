{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  #secretspath = builtins.toString inputs.nix-secrets;
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
  pluginsList = with pkgs; [
    age-plugin-fido2-hmac
    age-plugin-yubikey
    age-plugin-tpm
    age-plugin-ledger
  ];

  conf = {
    # NixOS configs
    nixos =
      lib.recursiveUpdate {
        imports = lib.singleton inputs.sops-nix.nixosModules.sops;

        #sops.defaultSopsFile = "${secretspath}/secrets.yaml";
        sops.defaultSopsFile = ../secrets.yaml;
        sops.validateSopsFiles = false;
        sops.age = {
          # Automatically import host SSH keys as age keys
          sshKeyPaths = map getKeyPath keys;
          # This will use an age key that is expected  to already be in the filesystem
          keyFile = "/var/lib/sops/keys.txt"; # Use age-key present on filesystem
          # Generate a new key if the key specified above does not exist
          generateKey = false;
        };
      }
      conf.common;

    # Home-Manager configs
    home = hm: let
      hm-config = hm.config;
    in
      lib.recursiveUpdate {
        imports = lib.singleton inputs.sops-nix.homeManagerModules.sops;
        sops.age = {
          sshKeyPaths = ["${hm-config.home.homeDirectory}/.ssh/nix-secret"];
          keyFile = "${hm-config.home.homeDirectory}/.config/sops/age/keys.txt";
          plugins = pluginsList;
        };
      }
      conf.common;

    # Shared Configs
    common = {
      sops.gnupg.sshKeyPaths = [];
      sops.age.plugins = pluginsList;
    };
  };
in
  conf.nixos
  // {
    home-manager.sharedModules = lib.singleton (hm: (conf.home hm));
  }
