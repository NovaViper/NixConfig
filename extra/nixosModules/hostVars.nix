{
  lib,
  config,
  options,
  username,
  ...
}:
let
  cfg = config.hostVars;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.hostVars = {
    configDirectory = lib.mkOption {
      type = lib.types.str;
      description = "The directory of the local nixos configuration.";
      default = null;
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "The directory for the user's folders. This should only be set if it's in a non-default location.";
      default = null;
    };
    scalingFactor = mkOption {
      type = types.number;
      description = "The scaling factor for the desktop. A scalingFactor of 1 --> 100% scaling.";
      default = 1;
    };
  };

  config.assertions = [
    { assertion = options.hostVars.configDirectory.isDefined; }
    #{ assertion = options.hostVars.homeDirectory.isDefined; }
    { assertion = options.hostVars.scalingFactor.isDefined; }
  ];
}
