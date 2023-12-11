{ lib, pkgs, outputs, ... }:

{
  imports = [
    ./font.nix
    ./theme.nix
    ./discord.nix

    # Music
    ./cider.nix
    #./jellyfin.nix

    # Browser
    #./firefox.nix
    ./vivaldi.nix

    # Backup solutions
    ./backup.nix

    # Terminals
    #./alacritty.nix
    ./wezterm.nix
    #./rio.nix
    #./kitty.nix
  ];

  xdg = {
    mimeApps.enable = true;

    # Make mimeapps.list be overriden by default
    configFile."mimeapps.list".force = true;
  };
}
