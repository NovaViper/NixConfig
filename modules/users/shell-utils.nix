{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkEnabledModule config "shell-utils" {
  home.packages = with pkgs; [
    # Fancy utilities
    timer # Cooler timer in terminal
    tldr # better man pages
    entr # run commands when files change!
    procs # Better ps
    ventoy-full # bootable USB solution
    dust # Better du and df
  ];
}
