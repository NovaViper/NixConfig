{ config, lib, ... }:
{
  services.borgbackup.repos = {
    ComputerBackups = {
      authorizedKeys = lib.singleton "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBPpqly8qaR00jPQ8Rq3nmRJk2wI62U6IarHGbfv3hii7H2WsA8n3RyKwQzXxA3Ob0fy5XhyiG0PdgaDjvM9ZIJUAAAAIc3NoOmtub3g=";
      path = "/mnt/sysbackup/ComputerBackups";
    };
  };
}
