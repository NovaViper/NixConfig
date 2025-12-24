{ config, lib, ... }:
{
  services.borgbackup.repos = {
    PCBackups = {
      authorizedKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOyfLHu4Ebn3CA9DgEurEPoYQDO2OyzvtCvRc2glDHajAAAAC3NzaDpib3JnUENB" # USBA
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIENmDvh9lgyp8/DhC6hiUW1JxJa6YITiUogYORbtLUSwAAAACHNzaDpib3Jn" # USBC
      ];
      path = "/mnt/sysbackup/PCBackups";
    };
  };
}
