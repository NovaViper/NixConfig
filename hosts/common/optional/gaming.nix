{ config, lib, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamemode.enable = true;
  };

  hardware = {
    # Enable Steam hardware compatibility
    steam-hardware.enable = true;

    # Enable OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ libva-utils ];
    };
  };
  # Allow Minecraft server ports
  networking.firewall.allowedTCPPorts = [ 25565 ];

  # Fixes SteamLink/Remote play crashing
  environment.systemPackages = with pkgs; [ libcanberra ];
}
