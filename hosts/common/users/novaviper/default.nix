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
in {
  # Special Variables
  variables.username = "novaviper";

  # Secrets
  age.secrets.novaviper-password.file = ageSecretsPath "novaviper/pass.age";

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
    hashedPasswordFile = config.age.secrets.novaviper-password.path;
    packages = with pkgs; [home-manager];
  };

  # Import Home-Manager config for host
  home-manager.users.novaviper =
    import ../../../../home/novaviper/${config.networking.hostName}.nix;

  # Make hardware clock use localtime.
  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    timeZone = lib.mkDefault "America/Chicago";
  };
}
