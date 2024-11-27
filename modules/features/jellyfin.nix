{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "jellyfin-player" {
  home.packages = with pkgs; [feishin];

  hm.xdg.mimeApps = {
    associations.added = {
      "x-scheme-handler/ame" = "feishin.desktop";
      "x-scheme-handler/feishin" = "feishin.desktop";
      "x-scheme-handler/itms" = "feishin.desktop";
      "x-scheme-handler/itmss" = "feishin.desktop";
      "x-scheme-handler/musics" = "feishin.desktop";
      "x-scheme-handler/music" = "feishin.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/ame" = "feishin.desktop";
      "x-scheme-handler/feishin" = "feishin.desktop";
      "x-scheme-handler/itms" = "feishin.desktop";
      "x-scheme-handler/itmss" = "feishin.desktop";
      "x-scheme-handler/musics" = "feishin.desktop";
      "x-scheme-handler/music" = "feishin.desktop";
    };
  };
}
