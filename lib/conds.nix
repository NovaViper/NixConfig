_: let
  exports = {
    defaultStateVersion = "24.05";
    runsDesktop = config: config.modules.desktop.enable;
    isWayland = config: (exports.runsDesktop config) && config.modules.desktop.wayland.enable;
    isX11 = config: (exports.runsDesktop config) && config.modules.desktop.x11.enable;
  };
in
  exports
