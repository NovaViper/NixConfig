{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  hm-config = config.hm;
  myself = "novaviper";
  sopsHashedPasswordFile = lib.mkIf (
    config.sops.secrets ? "passwords/${myself}"
  ) config.sops.secrets."passwords/${myself}".path;
in
{
  imports = myLib.utils.importFeatures [
    ### Shell
    "cli/shell/fish"
    #"cli/shell/zsh"

    ### Terminal Utils
    "cli/utilities"
    "cli/tmux"
  ];

  hm.userVars = {
    fullName = "Nova Leary";
    email = "coder.nova99@mailbox.org";
  };

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

  #time.timeZone = lib.mkForce "America/Chicago";
}
