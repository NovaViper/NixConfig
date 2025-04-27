{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      # Fancy utilities
      timer # Cooler timer in terminal
      entr # run commands when files change!
      procs # Better ps
      ventoy-full # bootable USB solution
      dust # Better du and df
      libnotify
    ]
    ++ lib.optionals osConfig.features.useWayland [wl-clipboard wl-clipboard-x11]
    ++ lib.optionals (!osConfig.features.useWayland) [
      xclip
      xsel
      xdotool
      xorg.xwininfo
      xorg.xprop
    ];
}
