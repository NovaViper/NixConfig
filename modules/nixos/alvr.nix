{ config, pkgs, lib, ... }:

with lib;

let cfg = config.programs.alvr;
in {
  options = {
    programs.alvr = {
      enable = mkEnableOption (lib.mdDoc "ALVR");

      package = mkPackageOption pkgs "alvr" { };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open the default ports in the firewall for the ALVR server.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 9943 9944 ];
      allowedUDPPorts = [ 9943 9944 ];
    };
  };
}
