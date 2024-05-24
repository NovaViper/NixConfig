{
  config,
  lib,
  pkgs,
  ...
}: let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Special Variables
  variables.username = "novaviper";

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
    hashedPasswordFile = config.sops.secrets.novaviper-password.path;
    packages = with pkgs; [home-manager];
  };

  sops.secrets.novaviper-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  # Import Home-Manager config for host
  home-manager.users.novaviper =
    import ../../../../home/novaviper/${config.networking.hostName}.nix;

  time.hardwareClockInLocalTime = lib.mkDefault true;
  # Setup automatic timezone detection
  services.automatic-timezoned.enable = true;
  location.provider = "geoclue2";

  # Set your time zone.
  #time.timeZone = lib.mkDefault "America/Chicago";
}
