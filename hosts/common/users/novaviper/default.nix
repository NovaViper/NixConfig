{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.novaviper = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Nova Leary";
    extraGroups = [ "networkmanager" "wheel" ]
      ++ ifTheyExist [ "libvirtd" "scanner" "i2c" "git" ];

    #openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/misterio/ssh.pub) ];
    #passwordFile = config.sops.secrets.novaviper-password.path;
    packages = with pkgs; [ home-manager ];
  };

  /* sops.secrets.novaviper-password = {
       sopsFile = ../../secrets.yaml;
       neededForUsers = true;
     }i;
  */

  home-manager.users.novaviper =
    import ../../../../home/novaviper/${config.networking.hostName}.nix;

  /* services.geoclue2 = {
       enableDemoAgent = lib.mkForce true;
       enable = true;
     };
  */

  # Setup automatic timezone detection and geolocation
  #location.provider = "geoclue2";
  #services.automatic-timezoned.enable = true;
  #services.localtimed.enable = true;
}
