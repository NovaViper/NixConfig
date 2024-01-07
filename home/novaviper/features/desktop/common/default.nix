{ lib, pkgs, outputs, config, ... }:

{
  imports = [
    ./font.nix
    ./gtk.nix
    ./qt.nix
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
    #./wezterm.nix
    #./rio.nix
    ./kitty.nix
  ];

  xdg = {
    # Allow modification of app assosications
    mimeApps.enable = true;

    # Make mimeapps.list be overriden by default
    configFile."mimeapps.list".force = true;

    # Enable desktop portal
    portal.enable = true;
  };
}
