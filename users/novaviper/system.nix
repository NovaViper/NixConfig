{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  myself = "novaviper";
  sopsHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."passwords/novaviper".path;
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
    hashedPasswordFile = sopsHashedPasswordFile;
  };
}
