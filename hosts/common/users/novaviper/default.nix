{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Special Variables
  variables.username = "novaviper";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.novaviper = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Nova Leary";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ]
      ++ ifTheyExist [ "libvirtd" "scanner" "i2c" "git" "gamemode" ];

    #openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/misterio/ssh.pub) ];
    #hashedPasswordFile = config.sops.secrets.novaviper-password.path;
    packages = with pkgs; [ home-manager ];
  };

  /* sops.secrets.novaviper-password = {
       sopsFile = ../../secrets.yaml;
       neededForUsers = true;
     };
  */

  services = {
    # Set the user allowed to use the syncthing service
    syncthing = lib.mkIf (config.services.syncthing.enable) {
      user = lib.mkForce config.variables.username;
    };

    geoclue2 = {
      enableDemoAgent = lib.mkForce true;
      enable = true;
    };

    # Setup automatic timezone detection
    #automatic-timezoned.enable = true;
    localtimed.enable = true;
  };

  # Setup geolocation
  location.provider = "geoclue2";

  home-manager.users.novaviper =
    import ../../../../home/novaviper/${config.networking.hostName}.nix;

}
