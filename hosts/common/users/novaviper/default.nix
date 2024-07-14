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
  # Special Variables
  variables.username = "novaviper";

  # Secrets
  age.secrets."${config.variables.username}-password" = {
    file = ageSecretsPath "${config.variables.username}/passwd.age";
    owner = "${config.variables.username}";
    group = "users";
  };

  users.users.${config.variables.username} = {
    isNormalUser = true;
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
    packages = with pkgs; [home-manager];
  };

  # Import Home-Manager config for host
  home-manager.users.${config.variables.username} =
    import ../../../../home/${config.variables.username}/${config.networking.hostName}.nix;

  # Make hardware clock use localtime.
  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    timeZone = lib.mkDefault "America/Chicago";
  };
}
