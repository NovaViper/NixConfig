{
  lib,
  ...
}:
let
  myself = "novaviper";
in
{
  users.users.${myself} = {
    openssh.authorizedKeys.keys = lib.singleton "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBPpqly8qaR00jPQ8Rq3nmRJk2wI62U6IarHGbfv3hii7H2WsA8n3RyKwQzXxA3Ob0fy5XhyiG0PdgaDjvM9ZIJUAAAAIc3NoOmtub3g=";
  };

  # Don't set anything since we're not going to be using git on the server
  # directly
  hm.programs.git = {
    userName = "";
    userEmail = "";
  };
}
