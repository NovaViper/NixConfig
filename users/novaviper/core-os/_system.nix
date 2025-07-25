{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  myself = "novaviper";
  sopsHashedPasswordFile = lib.mkIf (
    config.sops.secrets ? "passwords/novaviper"
  ) config.sops.secrets."passwords/novaviper".path;
in
{
  users.users.${myself} = {
    extraGroups = [
      "wheel"
      "i2c"
      "git"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = lib.singleton "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICkow+KpToZkMbhpqTztf0Hz/OWP/lWPCv47QNtZc6TaAAAADnNzaDpuaXhidWlsZGVy";
    hashedPasswordFile = sopsHashedPasswordFile;
  };
}
