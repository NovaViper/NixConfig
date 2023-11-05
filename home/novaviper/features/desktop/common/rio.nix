{ config, lib, pkgs, ... }:

{
  xdg = {
    configFile."rio/themes/dracula.toml".text = ''
      [colors]
      background       = '#282A36'
      black            = '#44475A'
      blue             = '#BD93F9'
      cursor           = '#F8F8F2'
      cyan             = '#8BE9FD'
      foreground       = '#F8F8F2'
      green            = '#50fa7b'
      magenta          = '#FF79C6'
      red              = '#FF5555'
      tabs             = '#494c62'
      tabs-active      = '#6a6e8e'
      white            = '#F8F8F2'
      yellow           = '#F1FA8C'
      dim-black        = '#393C4b'
      dim-blue         = '#AE7BF8'
      dim-cyan         = '#69C3dE'
      dim-foreground   = '#dfdfd9'
      dim-green        = '#06572F'
      dim-magenta      = '#FF60BB'
      dim-red          = '#FF3C3C'
      dim-white        = '#EFEFE1'
      dim-yellow       = '#E6A003'
      light-black      = '#6272A4'
      light-blue       = '#D6ACFF'
      light-cyan       = '#A4FFFF'
      light-foreground = '#f8f8f1'
      light-green      = '#69FF94'
      light-magenta    = '#FF92DF'
      light-red        = '#FF6E6E'
      light-white      = '#FFFFFF'
      light-yellow     = '#FFFFA5'
    '';
    mimeApps = {
      associations = {
        added = {
          "mimetype" = "rio.desktop";
          "application/x-terminal-emulator" = "rio.desktop";
          "x-terminal-emulator" = "rio.desktop";
        };
      };
      defaultApplications = {
        "mimetype" = "rio.desktop";
        "application/x-terminal-emulator" = "rio.desktop";
        "x-terminal-emulator" = "rio.desktop";
      };
    };
  };

  home.sessionVariables.TERMINAL = "rio";

  programs.rio = {
    enable = true;
    settings = {
      # Cursor
      #
      # Default cursor is Block
      # Other available options are: '_' and '|'
      cursor = "▇";

      # Blinking Cursor
      #
      # Default is false
      "blinking_cursor" = true;

      # Ignore theme selection foreground color
      #
      # Default is false
      "ignore_theme_selection_fg_color" = false;

      # Performance
      #
      # Set WGPU rendering performance
      # High: Adapter that has the highest performance. This is often a discrete GPU.
      # Low: Adapter that uses the least possible power. This is often an integrated GPU.
      performance = "High";

      # Theme
      #
      # It makes Rio look for the specified theme in the themes folder
      # (macos and linux: ~/.config/rio/themes/dracula.toml)
      # (windows: C:\Users\USER\AppData\Local\rio\themes\dracula.toml)
      theme = "dracula";

      # Padding-x
      #
      # define x axis padding (default is 10)
      # "padding-x" = 10;

      # Option as Alt
      #
      # This config only works on MacOs.
      # Possible choices: 'both', 'left' and 'right'.
      # "option-as-alt" = "left";

      # Window configuration
      #
      # • width - define the intial window width.
      #   Default: 600
      #
      # • height - define the inital window height.
      #   Default: 400
      #
      # • mode - define how the window will be created
      #     - "Windowed" (default) is based on width and height
      #     - "Maximized" window is created with maximized
      #     - "Fullscreen" window is created with fullscreen
      window = {
        width = 1200;
        height = 800;
        mode = "Windowed";
      };

      # Background configuration
      #
      # • opacity - changes the background transparency state
      #   Default: 1.0
      #
      # • mode - defines background mode bewteen "Color" and "Image"
      #
      # • image - Set an image as background
      #   Default: None
      # background = {
      #   mode = "Image";
      #   opacity = 1;
      #   image = {
      #     path = "/home/novaviper/Desktop/eastward.jpg";
      #     width = 200;
      #     height = 200;
      #     x = 0;
      #     y = 0;
      #   };
      # };

      # Window Height
      #
      # window-height changes the inital window height.
      #   Default: 400
      "window-height" = 400;

      # Fonts
      #
      # Configure fonts used by the terminal
      #
      # Note: You can set different font families but Rio terminal
      # will always look for regular font bounds whene
      #
      # You can also set family on root to overwritte all fonts
      # fonts.family = "cascadiamono";
      # Example
      # fonts = {
      #   size = 18;
      #   regular = {
      #     family = "MesloLGS Nerd Font";
      #     style = "normal";
      #     weight = 400;
      #   };
      #   bold = {
      #     family = "MesloLGS Nerd Font";
      #     style = "normal";
      #     weight = 800;
      #   };
      #   italic = {
      #     family = "MesloLGS Nerd Font";
      #     style = "italic";
      #     weight = 400;
      #   };
      #   "bold-italic" = {
      #     family = "MesloLGS Nerd Font";
      #     style = "italic";
      #     weight = 800;
      #   };
      # };
      fonts.family =
        "MesloLGS Nerd Font"; # This is currently broken since nixpkgs version is stuck on 0.19.0

      # Navigation
      #
      # "mode" - Define navigation mode
      #   • NativeTab (MacOs only)
      #   • CollapsedTab
      #   • BottomTab
      #   • TopTab
      #   • Breadcrumb
      #   • Plain
      #
      # "clickable" - Enable click on tabs to switch.
      # "use-current-path" - Use same path whenever a new tab is created.
      # "color-automation" - Set a specific color for the tab whenever a specific program is running.
      # "macos-hide-window-buttons" - (MacOS only) Hide window buttons
      navigation = {
        mode = "CollapsedTab";
        clickable = false;
        "use-current-path" = false;
        "color-automation" = [ ];
        #   "macos-hide-window-buttons" = false;
      };

      # Shell
      #
      # You can set `shell.program` to the path of your favorite shell, e.g. `/bin/fish`.
      # Entries in `shell.args` are passed unmodified as arguments to the shell.
      #
      # Default:
      #   - (macOS) user login shell
      #   - (Linux/BSD) user login shell
      #   - (Windows) powershell
      shell = {
        program = "/bin/zsh";
        args = [ "--login" ];
      };

      # Startup directory
      #
      # Directory the shell is started in. If this is unset the working
      # directory of the parent process will be used.
      #
      # This configuration only has effect if use-fork is disabled
      "working-dir" = "${config.home.homeDirectory}";

      # Environment variables
      #
      # The example below sets fish as the default SHELL using env vars
      # please do not copy this if you do not need
      "env-vars" = [
        "TERM=xterm-direct256"
        "COLORTERM=truecolor"
        "WINIT_X11_SCALE_FACTOR=1"
      ];

      # Disable render when unfocused
      #
      # This property disable renderer processes while Rio is unfocused.
      # "disable-renderer-when-unfocused" = false;

      # Use fork
      #
      # Defaults for POSIX-based systems (Windows is not configurable):
      # MacOS: spawn processes
      # Linux/BSD: fork processes
      # "use-fork" = true;

      # Colors
      #
      # Colors definition will overwrite any property in theme
      # (considering if theme folder does exists and is being used)
      # colors = {
      #   background = "#0F0D0E";
      #   foreground = "#F9F4DA";
      #   cursor = "#F38BA3";
      #   tabs = "#443d40";
      #   "tabs-active" = "#F38BA3";
      #   green = "#0BA95B";
      #   red = "#ED203D";
      #   blue = "#12B5E5";
      #   yellow = "#FCBA28";
      # };

      # Bindings
      #
      # Create custom Key bindings for Rio terminal
      # More information in: raphamorim.io/rio/docs/custom-key-bindings
      bindings = {
        keys = [{
          key = "q";
          "with" = "shift";
          action = "Quit";
        }
        #     {
        #       key = "home";
        #       "with" = "super | shift";
        #       bytes = [ 27 91 53 126 ];
        #     }
          ];
      };

      # Log level
      #
      # This property enables log level filter. Default is "OFF".
      developer = { "log-level" = "OFF"; };
    };
  };
}
