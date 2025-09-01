{ config, lib, ... }:
{
  services.borgbackup.repos = {
    PCBackups = {
      authorizedKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOyfLHu4Ebn3CA9DgEurEPoYQDO2OyzvtCvRc2glDHajAAAAC3NzaDpib3JnUENB" # USBA
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMSKi7F4wBS7gPE9oRVqQLnUNQ6LHphaUkSWi/Ixy9KPAAAAC3NzaDpib3JnUEND" # USBC
      ];
      path = "/mnt/sysbackup/PCBackups";
    };
  };
}
