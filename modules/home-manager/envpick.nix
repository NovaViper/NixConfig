{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.environment.desktop;
in {
  options.environment.desktop = mkOption {
    type = types.str;
    default = "";
    example = "kde";
    description = ''
      Determines what desktop environment you are using, setting this will make the config enable DE specific options.
    '';
  };
}
