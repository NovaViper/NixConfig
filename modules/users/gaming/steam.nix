{
  outputs,
  config,
  lib,
  pkgs,
  name,
  ...
}:
outputs.lib.mkDesktopModule config "steam" {
  home.packages = with pkgs; [protontricks keyutils goverlay ludusavi libcanberra protonup-qt];

  home.sessionVariables.ICED_BACKEND = "tiny-skia";

  nixos = {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          # Make Steam folder spawn in ~/.config instead of /home/USER
          HOME = "/home/${name}/.config";
        };
      };
      remotePlay.openFirewall = true;
    };

    # Enable Steam hardware compatibility
    hardware.steam-hardware.enable = true;

    # Fixes SteamLink/Remote play crashing
    environment.systemPackages = with pkgs; [libcanberra];

    xdg.mime = {
      defaultApplications."x-scheme-handler/steam" = "steam.desktop";
      addedAssociations."x-scheme-handler/steam" = "steam.desktop";
    };
  };

  xdg.mimeApps = {
    defaultApplications."x-scheme-handler/steam" = "steam.desktop";
    associations.added."x-scheme-handler/steam" = "steam.desktop";
  };
}
