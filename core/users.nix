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
}: let
  userPath = path: user: ../users/${user}/${path};
in {
  # NixOS user setup
  users.users = let
    userOpts = user: {
      isNormalUser = lib.mkDefault true;
      useDefaultShell = true; # Use the shell environment module declaration
      description = myLib.utils.getUserHMVar' "userVars.fullName" user config;
    };
    userConfigs = builtins.listToAttrs (map (user: lib.nameValuePair user (userOpts user)) allUsers);
  in
    userConfigs;

  # Home-manager user setup
  home-manager.users = let
    userOpts = user: {
      imports = myLib.slimports {
        optionalPaths = [
          (userPath "home.nix" user)
          (userPath "hosts/${hostname}.nix" user)
          (userPath "config" user)
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
