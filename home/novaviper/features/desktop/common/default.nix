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
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      gtkUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };
    mimeApps.enable = true;
  };

  # Make mimeapps.list be overriden by default
  xdg.configFile."mimeapps.list".force = true;
}
