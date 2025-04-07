{
  lib,
  config,
  options,
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

    scalingFactor = mkOption {
      type = types.int;
      description = "The scaling factor for the desktop. A scalingFactor of 1 --> 100% scaling.";
      default = null;
    };
  };

  config.assertions = [
    {assertion = options.hostVars.configDirectory.isDefined;}
    {assertion = options.hostVars.scalingFactor.isDefined;}
  ];
}
