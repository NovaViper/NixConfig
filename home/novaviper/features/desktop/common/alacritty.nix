{ config, pkgs, ... }:

{
  xdg.configFile."alacritty/themes/dracula.yml".source =
    ../../../dots/alacritty/dracula.yml;

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${config.xdg.configHome}/alacritty/themes/dracula.yml" ];
      env = {
        TERM = "xterm-256color";
        COLORTERM = "truecolor";
        WINIT_X11_SCALE_FACTOR = "1";
      };
      window = {
        dimensions = {
          columns = 132;
          lines = 43;
        };
        # Spread additional padding evenly around the terminal content.
        dynamic_padding = false;
        # Window decorations
        #
        # Values for `decorations`:
        #     - full: Borders and title bar
        #     - none: Neither borders nor title bar
        #
        # Values for `decorations` (macOS only):
        #     - transparent: Title bar, transparent background and title bar buttons
        #     - buttonless: Title bar, transparent background and no title bar buttons
        decorations = "full";

        # Background opacity
        #
        # Window opacity as a floating point number from `0.0` to `1.0`.
        # The value `0.0` is completely transparent and `1.0` is opaque.
        opacity = 1.0;
        # Startup Mode (changes require restart)
        #
        # Values for `startup_mode`:
        #   - Windowed
        #   - Maximized
        #   - Fullscreen
        #
        # Values for `startup_mode` (macOS only):
        #   - SimpleFullscreen
        startup_mode = "Windowed";

        # Allow terminal applications to change Alacritty's window title.
        dynamic_title = true;
      };
      scrolling = {
        # Maximum number of lines in the scrollback buffer.
        # Specifying '0' will disable scrolling.
        history = 10000;

        # Scrolling distance multiplier.
        multiplier = 3;
      };
      font = {
        # Normal (roman) font face
        normal = {
          # Font family
          #
          # Default:
          #   - (macOS) Menlo
          #   - (Linux/BSD) monospace
          #   - (Windows) Consolas
          family = "MesloLGS Nerd Font";

          # The `style` can be specified to pick a specific face.
          style = "Regular";
        };
        # Bold font face
        bold = {
          # Font family
          #
          # If the bold family is not specified, it will fall back to the
          # value specified for the normal font.
          family = "MesloLGS Nerd Font";

          # The `style` can be specified to pick a specific face.
          style = "Bold";
        };
        # Italic font face
        italic = {
          # Font family
          #
          # If the italic family is not specified, it will fall back to the
          # value specified for the normal font.
          family = "MesloLGS Nerd Font";

          # The `style` can be specified to pick a specific face.
          style = "Italic";
        };
        # Bold italic font face
        bold_italic = {
          # Font family
          #
          # If the bold italic family is not specified, it will fall back to the
          # value specified for the normal font.
          family = "MesloLGS Nerd Font";

          # The `style` can be specified to pick a specific face.
          style = "Bold Italic";
        };
        # Point size
        size = 11.0;

        # Offset is the extra space around each character. `offset.y` can be thought
        # of as modifying the line spacing, and `offset.x` as modifying the letter
        # spacing.
        offset = {
          x = 0;
          y = 0;
        };

        # Glyph offset determines the locations of the glyphs within their cells with
        # the default being at the bottom. Increasing `x` moves the glyph to the
        # right, increasing `y` moves the glyph upward.
        glyph_offset = {
          x = 0;
          y = 0;
        };

        # Use built-in font for box drawing characters.
        #
        # If `true`, Alacritty will use a custom built-in font for box drawing
        # characters (Unicode points 2500 - 259f).
        #
        builtin_box_drawing = true;
      };

      # If `true`, bold text is drawn using the bright color variants.
      draw_bold_text_with_bright_colors = false;

      bell = {
        # Visual Bell Animation
        #animation: EaseOutExpo

        # Duration of the visual bell flash in milliseconds.
        duration = 0;

        # Visual bell animation color.
        #color: '#ffffff'

        # Bell Command
        command = "xkbbell";
      };
      selection = {
        # This string contains all characters that are used as separators for
        # "semantic words" in Alacritty.
        #semantic_escape_chars: ",│`|:\"' ()[]{}<>\t"

        # When set to `true`, selected text will be copied to the primary clipboard.
        save_to_clipboard = true;
      };

      cursor = {
        # Cursor style
        style = {
          # Cursor shape
          #
          # Values for `shape`:
          #   - ▇ Block
          #   - _ Underline
          #   - | Beam
          shape = "Beam";

          # Cursor blinking state
          #
          # Values for `blinking`:
          #   - Never: Prevent the cursor from ever blinking
          #   - Off: Disable blinking by default
          #   - On: Enable blinking by default
          #   - Always: Force the cursor to always blink
          blinking = "Always";
        };

        # Vi mode cursor style
        #
        # If the vi mode cursor style is `None` or not specified, it will fall back to
        # the style of the active value of the normal cursor.
        #
        # See `cursor.style` for available options.
        vi_mode_style = "None";

        # Cursor blinking interval in milliseconds.
        blink_interval = 750;

        # Time after which cursor stops blinking, in seconds.
        #
        # Specifying '0' will disable timeout for blinking.
        #blink_timeout: 5

        # If this is `true`, the cursor will be rendered as a hollow box when the
        # window is not focused.
        unfocused_hollow = true;

        # Thickness of the cursor relative to the cell width as floating point number
        # from `0.0` to `1.0`.
        #thickness: 0.15
      };

      # Live config reload (changes require restart)
      live_config_reload = true;

      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [
          "--login"
          "-c"
          "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmuxp}/bin/tmuxp load ~/.config/tmuxp/session.yaml"
          #"tmux attach || tmux"
        ];
      };

      # Startup directory
      # Directory the shell is started in. If this is unset, or `None`, the working
      # directory of the parent process will be used.
      working_directory = "None";

      # Offer IPC using `alacritty msg` (unix only)
      #ipc_socket: true

      mouse = {
        # Click settings
        #
        # The `double_click` and `triple_click` settings control the time
        # alacritty should wait for accepting multiple clicks as one double
        # or triple click.
        double_click.threshold = 300;
        triple_click.threshold = 300;

        # If this is `true`, the cursor is temporarily hidden when typing.
        hide_when_typing = true;
      };

      mouse_bindings = [
        #  - { mouse: Right,                 action: ExpandSelection }
        #  - { mouse: Right,  mods: Control, action: ExpandSelection }
        #  - { mouse: Middle, mode: ~Vi,     action: PasteSelection  }
        # Paste selection with middle click
        {
          mouse = "Middle";
          action = "PasteSelection";
        }
      ];
    };
  };

  home.sessionVariables.TERMINAL = "alacritty";

  xdg.mimeApps = {
    associations = {
      added = {
        "mimetype" = "alacritty.desktop";
        "application/x-terminal-emulator" = "alacritty.desktop";
        "x-terminal-emulator" = "alacritty.desktop";
      };
    };
    defaultApplications = {
      "mimetype" = "alacritty.desktop";
      "application/x-terminal-emulator" = "alacritty.desktop";
      "x-terminal-emulator" = "alacritty.desktop";
    };
  };
}
