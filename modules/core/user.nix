{
  config,
  lib,
  options,
  username,
  ...
}: let
  internals = {
    cfg = config.variables.user;
    hostname = config.networking.hostName;
  };
in {
  options.variables.user = {
    fullName = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "John Doe";
      description = ''
        Your first and last name.
      '';
    };
    emailAddress = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "johndoe@example.com";
      description = ''
        Your email address.
      '';
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = ''
        The directory for the user's folders. This should only be set if it's in a non-default location.
      '';
      default = "/home/${username}";
    };
  };

  config = {
    #users.mutableUsers = false; # Makes it so we can only do password stuff via nixos, safer for not bricking system

    users.users.${username} = {
      isNormalUser = true;
      description = internals.cfg.fullName;
    };

    # Make hardware clock use localtime.
    time.hardwareClockInLocalTime = lib.mkDefault true;
    # Set UTC as default timezone, users can override if they want to
    time.timeZone = lib.mkDefault "UTC";

    assertions = [
      #{assertion = options.variables.user.fullName.isDefined;}
      #{assertion = options.variables.user.emailaddress.isDefined;}
      {assertion = options.variables.user.homeDirectory.isDefined;}
    ];
  };
}
