{
  config,
  lib,
  options,
  username,
  ...
}: let
  internals = {
    cfg = config.variables;
    cfg-user = internals.cfg.user;
    hostname = config.networking.hostName;
  };
in {
  options.variables = {
    defaultTerminal = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    defaultBrowser = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    defaultTextEditor = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    user = {
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
  };

  config = lib.mkMerge [
    # Enable defined terminal module and set it as the default TERMINAL program
    (lib.mkIf ((lib.conds.runsDesktop config) && internals.cfg.defaultTerminal != null) {
      home.sessionVariables.TERMINAL = internals.cfg.defaultTerminal;

      modules.${internals.cfg.defaultTerminal}.enable = true;
    })

    # Enable defined browser module
    (lib.mkIf ((lib.conds.runsDesktop config) && internals.cfg.defaultBrowser != null) {
      modules.${internals.cfg.defaultBrowser}.enable = true;
    })

    # Enable defined text editor module
    (lib.mkIf (internals.cfg.defaultTextEditor != null) {
      modules.${internals.cfg.defaultTextEditor}.enable = true;
    })

    # Configure the user
    {
      # Makes it so we can only do password stuff via nixos, safer for not bricking system
      #users.mutableUsers = false;

      users.users.${username} = {
        isNormalUser = true;
        description = internals.cfg-user.fullName;
      };

      time = {
        hardwareClockInLocalTime = lib.mkDefault true;
        # Set UTC as default timezone, users can override if they want to
        timeZone = lib.mkDefault "UTC";
      };
    }

    {
      assertions = [
        #{assertion = options.variables.user.fullName.isDefined;}
        #{assertion = options.variables.user.emailaddress.isDefined;}
        {assertion = options.variables.user.homeDirectory.isDefined;}
        {
          assertion = (internals.cfg.defaultTerminal != null) -> config.modules.desktop.enable;
          message = "variables.defaultTerminal must be defined when modules.desktop is enabled!";
        }

        {
          assertion = (internals.cfg.defaultBrowser != null) -> config.modules.desktop.enable;
          message = "variables.defaultBrowser must be defined when modules.desktop is enabled!";
        }
      ];
    }
  ];
}
