{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  myself = "novaviper";
in
{
  users.users.${myself} = {
    openssh.authorizedKeys.keys = lib.singleton "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBPpqly8qaR00jPQ8Rq3nmRJk2wI62U6IarHGbfv3hii7H2WsA8n3RyKwQzXxA3Ob0fy5XhyiG0PdgaDjvM9ZIJUAAAAIc3NoOmtub3g=";
  };
}
