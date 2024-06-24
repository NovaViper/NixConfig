{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  ageSecretsPath = path: "${inputs.self}/secrets/${path}";
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."${config.variables.username}-password".path;
in {
  # Special Variables
  variables.username = "novaviper";

  users.mutableUsers = false;
  users.users.novaviper = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "novaviper";
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

  # Secrets
  age.secrets."${config.variables.username}-password".file = ageSecretsPath "${config.variables.username}/passwd.age";

  # Import Home-Manager config for host
  home-manager.users.novaviper =
    import ../../../../home/novaviper/${config.networking.hostName}.nix;

  # Make hardware clock use localtime.
  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    timeZone = lib.mkDefault "America/Chicago";
  };
}
