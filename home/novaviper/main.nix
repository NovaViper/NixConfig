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
  sopsHashedPasswordFile = lib.mkIf (
    config.sops.secrets ? "passwords/${username}"
  ) config.sops.secrets."passwords/${username}".path;
in
{
  imports = myLib.utils.importFeatures {
    cli = [
      "shell/fish"
      "multiplexer/zellij"
    ];
    "cli/ux" = [
      "zoxide"
      "eza"
      "fzf"
      "bat"
    ];

    "cli/behavior" = [
      "pay-respects"
      "direnv"
    ];
    apps = [
      "yazi"
      "pass"
      "fastfetch"
      "btop"
    ];
  };

  vars.user = {
    fullName = "Nova Leary";
    email = "code4nova@aluwux.me";
  };

  users.users.${username} = {
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

  hm.programs.git = {
    settings = {
      user = {
        name = "NovaViper";
        email = config.vars.user.email;
      };
    };
    signing = {
      format = "openpgp";
      signByDefault = true;
      key = "E5E6D90A268AC09D";
    };
  };

  #time.timeZone = lib.mkForce "America/Chicago";
}
