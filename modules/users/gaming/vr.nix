{
  config,
  osConfig,
  pkgs,
  outputs,
  name,
  ...
}:
outputs.lib.mkDesktopModule config "vr" {
  # Add packages necessary for VR
  home.packages = with pkgs; [
    android-tools
    android-udev-rules
    BeatSaberModManager
    helvum
  ];

  xdg = {
    desktopEntries = {
      "BeatSaberModManager" = {
        name = "Beat Saber ModManager";
        genericName = "Game";
        exec = "BeatSaberModManager";
        icon = "${pkgs.BeatSaberModManager}/lib/BeatSaberModManager/Resources/Icons/Icon.ico";
        type = "Application";
        categories = ["Game"];
        startupNotify = true;
        comment = "Beat Saber ModManager is a mod manager for Beat Saber";
      };
    };

    configFile = {
      "alvr/session.json" = outputs.lib.mkIf (builtins.pathExists ./dotfiles/alvr) (outputs.lib.mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "alvr/session.json";
      });
      /*
        "openxr/1/active_runtime.json"= outputs.lib.mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "alvr/active_runtime.json";
      };
      */
    };
  };

  nixos = {
    # Enable ALVR module on NixOS
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };

    # Fixes issue with SteamVR not starting
    system.activationScripts.fixSteamVR = "${pkgs.libcap}/bin/setcap CAP_SYS_NICE+ep /home/${name}/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";

    programs.nix-ld.libraries = with pkgs;
      [
        # Steam VR
        procps
        usbutils
        udev
        dbus
      ]
      ++ outputs.lib.optionals (outputs.lib.mkIf osConfig.environment.sessionVariables.LIBVA_DRIVER_NAME == "nvidia") [
        config.boot.kernelPackages.nvidiaPackages.latest
        nvidia-vaapi-driver
      ];
  };
}
