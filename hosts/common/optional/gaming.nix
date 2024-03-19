{ config, lib, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          softrealtime = "off";
          inhibit_screensaver = 1;
        };
        /* gpu = lib.mkMerge [
             # General
             ({
               apply_gpu_optimisations = "accept-responsibility";
               gpu_device = 0;
             })
             # Nvidia
             (lib.mkIf (config.variables.machine.gpu == "nvidia") {
               nv_powermizer_mode = 1;
             })
           ];
        */
        custom = {
          start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
    alvr = {
      enable = config.variables.useVR;
      openFirewall = true;
    };
  };

  hardware = {
    # Enable Steam hardware compatibility
    steam-hardware.enable = true;

    # Enable OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs;
        [ libva-utils vaapiVdpau libvdpau-va-gl ]
        ++ lib.optionals (config.variables.machine.gpu == "nvidia")
        [ nvidia-vaapi-driver ];
    };
  };

  # Allow Minecraft server ports
  networking.firewall.allowedTCPPorts = [ 25565 24454 ];

  # Fixes SteamLink/Remote play crashing, add packages necessary for VR
  environment = {
    # Necessary to make Minecraft Wayland GLFW work with Wayland+Nvidia
    sessionVariables.__GL_THREADED_OPTIMIZATIONS =
      lib.mkIf (config.variables.machine.gpu == "nvidia") "0";
    systemPackages = with pkgs;
      [ libcanberra protonup-qt ] ++ lib.optionals (config.variables.useVR) [
        android-tools
        android-udev-rules
        sidequest
        BeatSaberModManager
        helvum
      ];
  };

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
