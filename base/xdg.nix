{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  environment.sessionVariables = {
    #XDG_CACHE_HOME = "\${HOME}/.cache";
    #XDG_CONFIG_HOME = "\${HOME}/.config";
    #XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    XDG_BIN_HOME = "\${HOME}/.local/bin";

    ANDROID_USER_HOME = "\${XDG_DATA_HOME}/android";
    CUDA_CACHE_PATH = "\${XDG_CACHE_HOME}/nv/";
    TLDR_CACHE_DIR = "\${XDG_CACHE_HOME}/tldr";
    NPM_CONFIG_USERCONFIG = "$\{XDG_CONFIG_HOME}/npm/npmrc";
  };

  hm.home = {
    preferXdgDirectories = true;
    sessionPath = [ "${config.environment.sessionVariables.XDG_BIN_HOME}" ];
    shellAliases = {
      wget = ''wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'';
    };
  };

  hm.xdg.configFile."npm/npmrc".text = ''
    prefix=${hm-config.xdg.dataHome}/npm
    cache=${hm-config.xdg.cacheHome}/npm
    tmp=$XDG_RUNTIME_DIR/npm
    init-module=${hm-config.xdg.configHome}/npm/config/npm-init.js
  '';

  hm.xdg.enable = true;

  hm.xresources.path = lib.mkForce "${hm-config.xdg.configHome}/.Xresources";

  hm.gtk = {
    enable = if (config.features.desktop != null) then true else false;
    gtk2.configLocation = lib.mkForce "${hm-config.xdg.configHome}/gtk-2.0/gtkrc";
  };
}
