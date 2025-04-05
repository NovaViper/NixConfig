{
  config,
  lib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
  hm.home.packages = with pkgs;
    [
      # Fancy utilities
      timer # Cooler timer in terminal
      tldr # better man pages
      entr # run commands when files change!
      procs # Better ps
      ventoy-full # bootable USB solution
      dust # Better du and df
      libnotify
    ]
    ++ lib.optionals (config.features.useWayland) [wl-clipboard wl-clipboard-x11]
    ++ lib.optionals (!config.features.useWayland) [
      xclip
      xsel
      xdotool
      xorg.xwininfo
      xorg.xprop
    ];
}
