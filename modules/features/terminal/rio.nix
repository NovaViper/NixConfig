{
  config,
  lib,
  ...
}: let
  hm-config = config.hm;
in
  lib.utilMods.mkDesktopModule config "rio" {
    hm.xdg.mimeApps = let
      defaultApplications = {
        "mimetype" = "rio.desktop";
        "application/x-terminal-emulator" = "rio.desktop";
        "x-terminal-emulator" = "rio.desktop";
      };
    in
      lib.mkIf (config.variables.defaultTerminal == "rio") {
        enable = true;
        inherit defaultApplications;
        associations.added = defaultApplications;
      };

    hm.programs.rio.enable = true;

    hm.programs.rio.settings = {
      editor.program = hm-config.home.sessionVariables.EDITOR;
      editor.args = [];

      cursor.shape = "block";
      cursor.blinking = true;

      working-dir = config.variables.user.homeDirectory;

      env-vars = [
        "TERM=xterm-256color"
        "COLORTERM=truecolor"
        "WINIT_X11_SCALE_FACTOR=1"
      ];

      window = {
        # FIXME: Add fonts for machine types
        /*
          width =
          if (config.variables.machine.buildType == "laptop")
          then 1000
          else 1200;
        height =
          if (config.variables.machine.buildType == "laptop")
          then 600
          else 800;
        */
        mode = "Windowed";
        blur = true;
      };

      renderer = {
        performance = "High";
        backend = "Automatic";
        disable-renderer-when-unfocused = false;
      };

      # Rio has multiple styles of showing navigation/tabs
      navigation.mode = lib.mkIf hm-config.programs.tmux.enable "Plain";
    };
  }
