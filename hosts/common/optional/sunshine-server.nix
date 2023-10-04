{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ sunshine ];

  networking.firewall = {
    allowedTCPPortRanges = [{
      from = 47984;
      to = 48010;
    }];
    allowedUDPPortRanges = [{
      from = 47998;
      to = 48010;
    }];
  };

  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };

  # Requires to simulate input
  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  systemd.user.services.sunshine = {
    description = "sunshine";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = { ExecStart = "${config.security.wrapperDir}/sunshine"; };
  };
}
