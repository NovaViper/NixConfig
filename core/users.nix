{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.userVars;
in {
  userVars.username = username;

  users.users.${cfg.username} = {
    isNormalUser = true;
    useDefaultShell = true; # Use the shell environment module declaration
    description = cfg.fullName;
  };

  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    # Set UTC as default timezone, users can override if they want to
    timeZone = lib.mkDefault "UTC";
  };
}
