{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  myself = "novaviper";
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."novaviper-password".path;
in {
  users.users.${myself} = {
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "scanner"
      "i2c"
      "git"
      "gamemode"
      "networkmanager"
      "libvirtd"
      "docker"
    ];
    openssh.authorizedKeys.keys = lib.singleton "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICkow+KpToZkMbhpqTztf0Hz/OWP/lWPCv47QNtZc6TaAAAADnNzaDpuaXhidWlsZGVy";
    hashedPasswordFile = agenixHashedPasswordFile;
  };

  age.identityPaths = lib.mkOptionDefault (myLib.secrets.mkSecretIdentities ["age-yubikey-identity-4416b57b.pub"]);

  # User Secrets
  age.secrets."novaviper-password" = myLib.secrets.mkSecretFile {
    user = myself;
    source = "passwd.age";
  };
}
