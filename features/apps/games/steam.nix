{
  config,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
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
      extraLibraries = pkgs: [pkgs.xorg.libxcb];
      extraBwrapArgs = [
        "--bind $HOME/.config/.steam $HOME"
        "--unsetenv XDG_CACHE_HOME"
        "--unsetenv XDG_CONFIG_HOME"
        "--unsetenv XDG_DATA_HOME"
        "--unsetenv XDG_STATE_HOME"
      ];
    };
    remotePlay.openFirewall = true;
  };

  xdg.mime = {
    defaultApplications."x-scheme-handler/steam" = "steam.desktop";
    addedAssociations."x-scheme-handler/steam" = "steam.desktop";
  };

  hm.xdg = {
    userDirs.extraConfig.XDG_GAME_DIR = "${hm-config.home.homeDirectory}/Games";

    mimeApps = {
      defaultApplications."x-scheme-handler/steam" = "steam.desktop";
      associations.added."x-scheme-handler/steam" = "steam.desktop";
    };
  };
}
