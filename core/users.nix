{
  config,
  lib,
  users,
  ...
}: {
  users.users = lib.listToAttrs (
    map (user: {
      name = "${user}";
      value = {
        isNormalUser = true;
        useDefaultShell = true; # Use the shell environment module declaration
        description = "${config.userVars.${user}.fullName}";
      };
    })
    users
  );

  time = {
    hardwareClockInLocalTime = lib.mkDefault true;
    # Set UTC as default timezone, hosts can override if they want to
    timeZone = lib.mkDefault "UTC";
  };
}
