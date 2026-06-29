{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  username,
  ...
}:
let
  hm-config = config.hm;
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
    nixos = lib.recursiveUpdate {
      imports = [
        inputs.sops-nix.nixosModules.sops
        # Alias for declaring sops options from Home-Manager
        (lib.mkAliasOptionModule [ "sopsHome" ] [ "home-manager" "users" username "sops" ])
      ];
      home-manager.sharedModules = lib.singleton inputs.sops-nix.homeManagerModules.sops;

      # sops.defaultSopsFile = myLib.secrets.mkSecretFile {
      #   source = "secrets.yaml";
      #   subDir = ["hosts" "${config.networking.hostName}"];
      # };

      sops.age = {
        # Automatically import host SSH keys as age keys
        sshKeyPaths = map getKeyPath keys;
        # This will make sops use an age key that is expected to already be in the filesystem (aka the access key)
        keyFile = "/var/lib/sops/keys.txt"; # Use age-key present on filesystem
        # Generate a new key if the key specified above does not exist
        generateKey = false;
      };

      # Create user password secrets
      sops.secrets."passwords/${username}" = myLib.secrets.mkSecretFile {
        source = "secrets.yaml";
        subDir = "hosts";
        neededForUsers = true;
      };
    } conf.common;

    # Home-Manager configs
    home = lib.recursiveUpdate {
      # sops.defaultSopsFile = myLib.secrets.mkSecretFile {
      #   source = "secrets.yaml";
      #   subDir = ["users" "${username}"];
      # };
      sops.age = {
        sshKeyPaths = [ "${hm-config.home.homeDirectory}/.ssh/nix-secret" ];
        # Access key for users
        keyFile = "${hm-config.home.homeDirectory}/.config/sops/age/keys.txt";
        plugins = pluginsList;
      };

      sops.secrets = {
        "keys/${username}" = myLib.secrets.mkSecretFile {
          destination = "${hm-config.home.homeDirectory}/.ssh/nix-secret";
          source = "secrets.yaml";
          subDir = "users";
        };
      };
    } conf.common;

    # Shared Configs
    common = {
      sops.validateSopsFiles = false;
      sops.gnupg.sshKeyPaths = [ ];
      sops.age.plugins = pluginsList;
    };
  };
in
conf.nixos
// {
  hm = conf.home;
}
