{ pkgs, ... }:
{
  # Enable Flatpak
  services.flatpak.enable = true;

  # Create folder where all fonts are linked to /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # Automatically configure it
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
