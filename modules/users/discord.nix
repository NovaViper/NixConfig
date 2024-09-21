{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkDesktopModule config "discord" {
  home.packages = with pkgs;
    if (outputs.lib.isWayland config)
    then [discord-wayland vesktop]
    else [discord];
}
