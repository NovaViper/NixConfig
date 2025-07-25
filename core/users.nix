{
  config,
  lib,
  myLib,
  primaryUser,
  extraUsers,
  allUsers,
  inputs,
  pkgs,
  hostname,
  ...
}:
let
  userPath = path: user: ../users/${user}/${path};
in
{
  # NixOS user setup
  users = {
    mutableUsers = false; # Only allow declarative credentials; Required for password to be set via sops during system activation!
    users =
      let
        userOpts = user: {
          isNormalUser = lib.mkDefault true;
          useDefaultShell = true; # Use the shell environment module declaration
          description = myLib.utils.getUserHMVar' "userVars.fullName" user config;
        };
        userConfigs = builtins.listToAttrs (map (user: lib.nameValuePair user (userOpts user)) allUsers);
      in
      userConfigs;
  };

  # Home-manager user setup
  home-manager.users =
    let
      userOpts = user: {
        imports = myLib.slimports {
          optionalPaths = [
            (userPath "core-home" user) # Common user definitions (and other user configurations) that gets imported for all hosts
            (userPath "hosts-home/${hostname}.nix" user) # Host specific user configurations that get imported for a particular host
          ];
        };
      };
      userConfigs = builtins.listToAttrs (map (user: lib.nameValuePair user (userOpts user)) allUsers);
    in
    userConfigs;

  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    # Set UTC as default timezone, users can override if they want to
    timeZone = lib.mkDefault "UTC";
  };
}
