{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  # A bunch of extra packages too small for their own file
  home.packages =
    with pkgs;
    [
      # Fancy utilities
      timer # Cooler timer in terminal
      tldr # better man pages
      entr # run commands when files change!
      procs # Better ps
      dust # Better du and df
    ]
    ++ lib.optionals osConfig.features.useWayland [
      wl-clipboard
      wl-clipboard-x11
    ]
    ++ lib.optionals (!osConfig.features.useWayland && osConfig.features.desktop != null) [
      xclip
      xsel
      xdotool
      xorg.xwininfo
      xorg.xprop
    ]
    ++ lib.optionals (osConfig.features.desktop != null) [
      libnotify
    ];
}
