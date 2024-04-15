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
    packages = with pkgs; [home-manager];
  };

  # Import Home-Manager config for host
  home-manager.users.novaviper =
    import ../../../../home/novaviper/${config.networking.hostName}.nix;

  services = {
    geoclue2 = {
      enable = true;
      enableDemoAgent = lib.mkForce true;
      submitData = true;
      appConfig.vivaldi = {
        isAllowed = true;
        isSystem = false;
      };
    };

    # Setup automatic timezone detection
    automatic-timezoned.enable = true;
    #localtimed.enable = true;
  };

  # Set your time zone.
  #time.timeZone = lib.mkDefault "America/Chicago";
}
