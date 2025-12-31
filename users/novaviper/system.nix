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
    "cli/multiplexer/tmux"
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
    #
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJWAjNX9W7yLMAj7Y5tkGmXubkX7YxiK86RKPWNlL3JmAAAADnNzaDpuaXhidWlsZGVy" # USBA
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJ7BJkxw7uEAeun8irHZPS0Z2MUySBhYAqwsWGLwS8OuAAAADnNzaDpuaXhidWlsZGVy" # USBC
    ];
    hashedPasswordFile = sopsHashedPasswordFile;
  };

  #time.timeZone = lib.mkForce "America/Chicago";
}
