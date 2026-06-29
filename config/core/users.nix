{
  config,
  lib,
  username,
  ...
}:
let
  userVar = config.hm.userVars;
in
{
  # Only allow declarative credentials; Required for password to be set via sops during system activation!
  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = lib.mkDefault true;
    description = userVar.fullName;
    # Use the shell environment module declaration
    useDefaultShell = true;
  };

  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    # Set UTC as default timezone, users can override if they want to
    timeZone = lib.mkDefault "UTC";
  };
}
