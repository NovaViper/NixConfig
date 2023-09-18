{ config, lib, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamemode.enable = true;
  };

  # Enable Steam hardware compatibility
  hardware.steam-hardware.enable = true;

  # Allow Minecraft server ports
  networking.firewall.allowedTCPPorts = [ 25565 ];

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libva-utils ];
  };
}
