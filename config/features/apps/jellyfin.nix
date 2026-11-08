{
  pkgs,
  ...
}:
let
  # Keep Feishin independent of the desktop player's config and script collection.
  feishinMpv = pkgs.writeShellScriptBin "mpv" ''
    exec ${pkgs.mpv-unwrapped}/bin/mpv --no-config --load-scripts=no "$@"
  '';
  feishin = pkgs.symlinkJoin {
    name = "feishin-${pkgs.feishin.version}";
    paths = [ pkgs.feishin ];
    postBuild = ''
      # Copy the launcher before editing it, preserving the packaged Electron flags.
      rm "$out/bin/feishin"
      cp ${pkgs.feishin}/bin/feishin "$out/bin/feishin"
      chmod u+w "$out/bin/feishin"
      substituteInPlace "$out/bin/feishin" \
        --replace-fail '${pkgs.mpv-unwrapped}/bin' '${feishinMpv}/bin'
      ln -s ${feishinMpv}/bin/mpv "$out/bin/feishin-mpv"
    '';
    meta = pkgs.feishin.meta;
  };
in
{
  hm.home.packages = with pkgs; [
    feishin
    jellyfin-tui
    pear-desktop
  ];

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
