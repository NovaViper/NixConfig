{ config, pkgs, lib, ... }:

{
  imports = [ ../common ];

  variables.desktop.environment = "kde";

  xdg.mimeApps = {
    associations = {
      added = {
        "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
      };
    };
    defaultApplications = {
      "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
    };
  };

  # Kdiff configurations
  xdg.configFile."kdiff3rc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/misc/kdiff3rc";

  # Konsole settings
  xdg.dataFile = lib.mkIf config.variables.useKonsole {
    "konsole" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/konsole";
      recursive = true;
    };

    # Dolphin settings
    "kxmlgui5/dolphin/dolphinui.rc".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/dolphin/dolphinui.rc";

    # Yakuake settings
    "yakuake/skins/Dracula".source = fetchGit {
      url = "https://github.com/dracula/yakuake";
      rev = "591a705898763167dd5aca2289d170f91a85aa56";
    };
  };

  xdg.configFile."yakuakerc" = lib.mkIf config.variables.useKonsole {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/yakuake/yakuakerc";
  };

  programs.plasma = {
    enable = true;
    workspace.clickItemTo = "select";
    shortcuts.yakuake =
      lib.mkIf config.variables.useKonsole { toggle-window-state = "F12"; };
    configFile = {
      kglobalshortcutsrc.yakuake = lib.mkIf config.variables.useKonsole {
        "_k_friendly_name" = "Yakuake";
      };
      kwinrc.NightColor.Active = true;
      kcminputrc.Mouse.cursorTheme = "Dracula-cursors";
    };
  };

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/kdeconnect" ];
     };
  */

  /* xdg.desktopEntries."org.kde.konsole" = {
       name = "Konsole";
       genericName = "Terminal";
       exec = "konsole --layout ${config.xdg.dataHome}/konsole/DefaultSplits.json";
       icon = "utilities-terminal";
       comment = "Command line access";
       type = "Application";
       terminal = false;
       categories = [ "Qt" "KDE" "System" "TerminalEmulator" ];
       mimeType = [ "text/html" "text/xml" ];
       startupNotify = true;
       actions = {
         "NewWindow" = {
           name = "Open a New Window";
           icon = "window-new";
           exec = "konsole";
         };
         "NewTab" = {
           name = "Open a New Tab";
           icon = "tab-new";
           exec = "konsole --new-tab";
         };
       };
       settings = {
         X-DocPath = "konsole/index.html";
         X-DBUS-StartupType = "Unique";
         X-KDE-AuthorizeAction = "shell_access";
         X-KDE-Shortcuts = "Ctrl+Alt+T";
         StartupWMClass = "konsole";
         Keywords =
           "terminal;console;script;run;execute;command;command-line;commandline;cli;bash;sh;shell;zsh;cmd;command prompt";
       };
     };
  */
}
