{

  config,
  lib,
  myLib,
  pkgs,
  username,
  ...
}:
{
  imports = myLib.utils.importFeatures {
    boot = [
      "disko"
      "pretty-plymouth"
    ];
    # theme = lib.singleton "catppuccin";
    hardware = [
      "bluetooth"
      "yubikey"
    ];
    services = lib.singleton "tailscale";
  };

  vars.host = {
    configDirectory = "/etc/nixos";
    scalingFactor = 1;
  };

  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGGrJs3zMfJ2hKV9Bsrv4L2OgvVnOo2bsh5cTmKvDp+kAAAACHNzaDprbm94" # USBA
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPDlcBvj1nzXUCL6JU9JIAImMBN5AXY8x590m7d15viJAAAACHNzaDprbm94" # USBC
    ];
  };

  hm.sops.secrets = lib.mkForce { };
}
