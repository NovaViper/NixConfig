{
  lib,
  config,
  options,
  primaryUser,
  ...
}: let
  cfg = config.hostVars;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.hostVars = {
    configDirectory = lib.mkOption {
      type = lib.types.str;
      description = "The directory of the local nixos configuration.";
      default = null;
    };
    primaryUser = mkOption {
      type = types.str;
      description = ''
        The primary user of the host, refers to the variable passed into the flake
      '';
      default = "${primaryUser}";
      readOnly = true;
    };

    scalingFactor = mkOption {
      type = types.int;
      description = "The scaling factor for the desktop. A scalingFactor of 1 --> 100% scaling.";
      default = null;
    };
  };

  config.assertions = [
    {assertion = options.hostVars.configDirectory.isDefined;}
    {assertion = options.hostVars.scalingFactor.isDefined;}
    {assertion = options.hostVars.primaryUser.isDefined;}
  ];
}
