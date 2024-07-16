{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}: let
  ageSecretsPath = path: "${self}/secrets/${path}";
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."${config.variables.username}-password".path;
in {
  imports = [../standard.nix];

  # Special Variables
  variables.username = "novaviper";

  # Secrets
  age.secrets."${config.variables.username}-password" = {
    file = ageSecretsPath "${config.variables.username}/passwd.age";
    owner = "${config.variables.username}";
    group = "users";
  };

  users.users.${config.variables.username} = {
    shell = pkgs.zsh;
    description = "${config.variables.username}";
    extraGroups =
      ["networkmanager" "wheel"]
      ++ ifTheyExist [
        "video"
        "audio"
        "libvirtd"
        "scanner"
        "i2c"
        "git"
        "gamemode"
      ];
    hashedPasswordFile = agenixHashedPasswordFile;
  };

  # Use US Central timezone
  time.timeZone = "America/Chicago";
}
