{ config, lib, ... }:
{
  services.borgbackup.repos = {
    PCBackups = {
      authorizedKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIClNMgY9EShoR6/tPZVgVsQ5zWkwiML09EWK8pw9cPTXAAAACHNzaDpib3Jn" # USBA
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIENmDvh9lgyp8/DhC6hiUW1JxJa6YITiUogYORbtLUSwAAAACHNzaDpib3Jn" # USBC
      ];
      path = "/mnt/sysbackup/PCBackups";
    };
  };
}
