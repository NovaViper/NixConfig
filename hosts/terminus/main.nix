{
  config,
  lib,
  myLib,
  username,
  ...
}:
{
  imports = myLib.utils.importFeatures {
    services = [
      "fail2ban"
    ];
  };

  vars.host.configDirectory = "/etc/nixos";

  # Terminus uses its own resident security keys instead of the shared host keys.
  users.users.${username} = {
    openssh.authorizedKeys.keys = lib.mkForce [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEH9PLGUC08nHDn2TLXNVNYNTKGZdsMy4iMArESCd0z0AAAADHNzaDp0ZXJtaW51cw==" # USBA
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMPh1IHCpIk5/ou2u235ovOroOqP02rwtwdzrm1wphWDAAAADHNzaDp0ZXJtaW51cw==" # USBC
    ];
  };

  # Emergency Maintenance User (Zeon) for remote access in case of a disaster
  users.users.zeon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."passwords/zeon".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAmzJI48g65BL/IGqHPXTl756jXpHpg6snAiXyo6/LN"
    ];
  };

  sops.secrets."passwords/zeon" = myLib.secrets.mkSecretFile {
    source = "secrets.yaml";
    subDir = [
      "hosts"
      "terminus"
    ];
    neededForUsers = true;
  };
  hm.sops.secrets = lib.mkForce { };
}
