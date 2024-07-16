# Standard file for most users, not necessary for every one; import as needed
{
  config,
  lib,
  pkgs,
  ...
}: let
  username = config.variables.username;
in {
  users.users.${username} = {
    isNormalUser = lib.mkForce true;
    packages = with pkgs; [home-manager];
  };

  # Import Home-Manager config for host
  home-manager.users.${config.variables.username} =
    lib.mkDefault (import ../../../home/${config.variables.username}/${config.networking.hostName}.nix);

  time = {
    # Make hardware clock use localtime.
    hardwareClockInLocalTime = lib.mkDefault true;
    # Set UTC as default timezone, users can override if they want to
    timeZone = lib.mkDefault "UTC";
  };
}
