_: let
  exports = rec {
    defaultStateVersion = "24.05";
    runsDesktop = config: config.modules.desktop.enable;
    isWayland = config: (runsDesktop config) && config.modules.desktop.wayland.enable;
    isX11 = config: (runsDesktop config) && config.modules.desktop.x11.enable;
  };
in
  exports
