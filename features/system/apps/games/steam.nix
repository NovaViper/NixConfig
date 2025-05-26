{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  environment.systemPackages = with pkgs; [
    heroic
    protonup-qt
    protontricks
    goverlay
    ludusavi
    pkgsCross.mingw32.wine-discord-ipc-bridge

    # Fixes SteamLink/Remote play crashing
    keyutils
    libcanberra
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable Steam hardware compatibility
  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    # Make Steam folder spawn in ~/.config instead of /home/USER
    package = pkgs.steam.override {
      extraLibraries = pkgs: [ pkgs.xorg.libxcb ];
    };
    remotePlay.openFirewall = true;
  };

  xdg.mime = {
    defaultApplications."x-scheme-handler/steam" = "steam.desktop";
    addedAssociations."x-scheme-handler/steam" = "steam.desktop";
  };

  home-manager.sharedModules = lib.singleton (
    hm:
    let
      hm-config = hm.config;
    in
    {
      xdg.userDirs.extraConfig.XDG_GAME_DIR = "${hm-config.home.homeDirectory}/Games";

      xdg.mimeApps = {
        defaultApplications."x-scheme-handler/steam" = "steam.desktop";
        associations.added."x-scheme-handler/steam" = "steam.desktop";
      };
    }
  );
}
