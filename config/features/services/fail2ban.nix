{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    jails.sshd.settings = {
      enabled = true;
      findtime = "10m";
    };
  };
}
