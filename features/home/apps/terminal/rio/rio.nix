{
  config,
  lib,
  myLib,
  ...
}:
{
  xdg.mimeApps =
    let
      defaultApplications = {
        "mimetype" = "rio.desktop";
        "application/x-terminal-emulator" = "rio.desktop";
        "x-terminal-emulator" = "rio.desktop";
      };
    in
    lib.mkIf (myLib.utils.getUserVars "defaultTerminal" config == "rio") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  programs.rio.enable = true;

  programs.rio.settings = {
    editor.program = config.home.sessionVariables.EDITOR;
    editor.args = [ ];

    cursor.shape = "block";
    cursor.blinking = true;

    working-dir = config.home.homeDirectory;

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
    navigation.mode = lib.mkIf config.programs.tmux.enable "Plain";
  };
}
