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

  # Fixes SteamLink/Remote play crashing, add packages necessary for VR
  environment.systemPackages = with pkgs;
    [ libcanberra ] ++ lib.optionals (config.variables.useVR) [
      android-tools
      android-udev-rules
      sidequest
      BeatSaberModManager
      helvum
    ];

  # Fixes issue with SteamVR not starting
  system.activationScripts = lib.mkIf (config.variables.useVR) {
    fixSteamVR =
      "${pkgs.libcap}/bin/setcap CAP_SYS_NICE+ep /home/${config.variables.username}/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
  };

  xdg.mime = {
    defaultApplications."x-scheme-handler/steam" = "steam.desktop";
    addedAssociations."x-scheme-handler/steam" = "steam.desktop";
  };
}
