{ config, lib, pkgs, ... }:
let c = config.lib.stylix.colors.withHashtag;
in {
  programs.cava = {
    enable = true;
    settings = {
      # Enable alacritty syncronized updates, removes flickering in alacritty
      output.alacritty_sync = 1;

      general = {
        mode = "normal";
        framerate = 60;
        sensitivity = 100;
        bars = 0;
        bar_width = 1;
        bar_spacing = 1;
      };

      smoothing = {
        # Enable the fancy Monstercat smoothing
        monstercat = 1;
        # Wave mode
        waves = 0;
        # Gravity percentage for "drop off"
        gravity = 100;
        # Adjusts the integral and gravity filters to keep the signal smooth
        noise_reduction = 77;
      };

      # Equalizer
      eq = {
        "1" = 1;
        "2" = 1;
        "3" = 1;
        "4" = 1;
        "5" = 1;
      };

      color = {
        gradient = 1;
        gradient_count = 8;
        gradient_color_1 = "'${c.base0C}'";
        gradient_color_2 = "'${c.base0D}'";
        gradient_color_3 = "'${c.base07}'";
        gradient_color_4 = "'${c.base0D}'";
        gradient_color_5 = "'${c.base0E}'";
        gradient_color_6 = "'${c.base0F}'";
        gradient_color_7 = "'${c.base0F}'";
        gradient_color_8 = "'${c.base08}'";
      };
    };
  };
}
