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
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."novaviper-password".path;
in {
  # Special Variables
  variables.username = "novaviper";

  # Secrets
  age.secrets."novaviper-password" = {
    file = ageSecretsPath "novaviper/passwd.age";
    owner = "novaviper";
    group = "users";
  };

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
    # Use if agenix isn't working
    password = "nixos";
    hashedPasswordFile = agenixHashedPasswordFile;
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
