{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = with pkgs; [sops];

  sops = {
    gnupg = {
      home = "/home/${config.variables.username}/.gnupg";
      sshKeyPaths = [];
    };
    age.sshKeyPaths = map getKeyPath keys;
  };

  # sops-nix will launch an scdaemon instance on boot, which will stay
  # alive and prevent the yubikey from working with any users that log
  # in later.
  # From: https://github.com/TLATER/dotfiles/blob/93791a4bd5682e34977ea9569ca315889601f624/nixos-config/yubikey.nix
  systemd.services.shutdownSopsGpg = {
    path = [pkgs.gnupg];
    script = ''
      gpgconf --homedir ${config.sops.gnupg.home} --kill gpg-agent
    '';
    wantedBy = ["multi-user.target"];
  };
}
