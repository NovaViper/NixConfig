{ config, lib, pkgs, ... }:

{
  theme = {
    package = pkgs.dracula-theme;
    name = "Dracula";
    cursorTheme = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };

    # Add Dracula theme to TTY
    consoleColors = [
      "282a36" # redefine 'black'          as 'dracula-bg'
      "6272a4" # redefine 'bright-black'   as 'dracula-comment'
      "ff5555" # redefine 'red'            as 'dracula-red'
      "ff7777" # redefine 'bright-red'     as '#ff7777'
      "50fa7b" # redefine 'green'          as 'dracula-green'
      "70fa9b" # redefine 'bright-green'   as '#70fa9b'
      "f1fa8c" # redefine 'brown'          as 'dracula-yellow'
      "ffb86c" # redefine 'bright-brown'   as 'dracula-orange'
      "bd93f9" # redefine 'blue'           as 'dracula-purple'
      "cfa9ff" # redefine 'bright-blue'    as '#cfa9ff'
      "ff79c6" # redefine 'magenta'        as 'dracula-pink'
      "ff88e8" # redefine 'bright-magenta' as '#ff88e8'
      "8be9fd" # redefine 'cyan'           as 'dracula-cyan'
      "97e2ff" # redefine 'bright-cyan'    as '#97e2ff'
      "f8f8f2" # redefine 'white'          as 'dracula-fg'
      "ffffff" # redefine 'bright-white'   as '#ffffff'
    ];
  };
}
