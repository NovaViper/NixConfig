{
  config,
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
  };

  nixos = {
    # Enable ALVR module on NixOS
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };

    # Fixes issue with SteamVR not starting
    system.activationScripts.fixSteamVR = "${pkgs.libcap}/bin/setcap CAP_SYS_NICE+ep /home/${name}/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
  };
}
