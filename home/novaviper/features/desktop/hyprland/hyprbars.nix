{ config, pkgs, lib, ... }:
let
  hyprbars = (pkgs.inputs.hyprland-plugins.hyprbars.override {
    # Make sure it's using the same hyprland package as we are
    hyprland = config.wayland.windowManager.hyprland.package;
  }).overrideAttrs (old: {
    # Yeet the initialization notification (I hate it)
    postPatch = (old.postPatch or "") + ''
      ${lib.getExe pkgs.gnused} -i '/Initialized successfully/d' main.cpp
    '';
  });
in {
  wayland.windowManager.hyprland = {
    plugins = [ hyprbars ];
    settings = {
      "plugin:hyprbars" = {
        bar_height = 25;
        bar_color = "0xee282828";
        "col.text" = "0xeeD8D8D8";
        #bar_text_font = config.fontProfiles.regular.family;
        bar_text_size = 12;
        hyprbars-button = [
          # Red close button
          "rgb(AB4642),12,,hyprctl dispatch killactive"
          # Green "maximize" (fullscreen) button
          "rgb(A1B56C),12,,hyprctl dispatch fullscreen 1"
          # Yellow "minimize" (send to special workspace) button
          "rgb(F7CA88),12,,hyprctl dispatch movetoworkspacesilent special"
        ];
      };
      bind = let
        barsEnabled = "hyprctl -j getoption plugin:hyprbars:bar_height | ${
            lib.getExe pkgs.jq
          } -re '.int != 0'";
        setBarHeight = height:
          "hyprctl keyword plugin:hyprbars:bar_height ${toString height}";
        toggleOn = setBarHeight
          config.wayland.windowManager.hyprland.settings."plugin:hyprbars".bar_height;
        toggleOff = setBarHeight 0;
      in [ "SUPER,m,exec,${barsEnabled} && ${toggleOff} || ${toggleOn}" ];
    };
  };
}
