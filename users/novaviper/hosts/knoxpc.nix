{
  lib,
  ...
}:
let
  myself = "novaviper";
in
{
  users.users.${myself} = {
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGGrJs3zMfJ2hKV9Bsrv4L2OgvVnOo2bsh5cTmKvDp+kAAAACHNzaDprbm94" # USBA
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPDlcBvj1nzXUCL6JU9JIAImMBN5AXY8x590m7d15viJAAAACHNzaDprbm94" # USBC
    ];
  };

  # Don't set anything since we're not going to be using git on the server
  # directly
  hm.programs.git.settings.user = {
    name = "";
    email = "";
  };
}
