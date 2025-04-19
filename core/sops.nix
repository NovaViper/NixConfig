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
in {
  imports = lib.singleton inputs.sops-nix.nixosModules.sops;

  sops = {
    #defaultSopsFile = "${secretspath}/secrets.yaml";
    defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;
    gnupg.sshKeyPaths = [];
    age = {
      plugins = with pkgs; [
        age-plugin-yubikey
        age-plugin-tpm
        age-plugin-ledger
      ];
      # Automatically import host SSH keys as age keys
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      #sshKeyPaths = [];
      # This will use an age key that is expected  to already be in the filesystem
      #keyFile = "/var/lib/sops-nix/key.txt"; # Use age-key present on filesystem
      keyFile = "/home/novaviper/.config/sops/age/keys.txt";
      # Generate a new key if the key specified above does not exist
      generateKey = false;
    };
  };

  # fix for https://github.com/Mic92/sops-nix/pull/680#issuecomment-2580744439
  # see https://github.com/NixOS/nixpkgs/blob/b33acd9911f90eca3f2b11a0904a4205558aad5b/nixos/lib/systemd-lib.nix#L473-L473
  systemd.services.sops-install-secrets.environment.PATH = let
    path = config.systemd.services.sops-install-secrets.path;
  in
    lib.mkForce "${lib.makeBinPath path}:${lib.makeSearchPathOutput "bin" "sbin" path}";
  systemd.services.sops-install-secrets.path = with pkgs; [coreutils age-plugin-yubikey];
  systemd.services.sops-install-secrets.after = ["pcscd.socket"];
  systemd.services.sops-install-secrets.requires = ["pcscd.socket"];
  /*
    home-manager.sharedModules = lib.singleton (hm: let hm-config = hm.config; in {
    sops = {
      age.keyFile = "${hm-config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  });
  */
}
