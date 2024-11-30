{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkDesktopModule config "flatpak" {
  # Enable Flatpak
  services.flatpak.enable = true;

  # Create folder where all fonts are linked to /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # Automatically configure it
  /*
    systemd.services.configure-flathub-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };
  */

  environment.etc = {
    "flatpak/remotes.d/flathub.flatpakrepo".source = pkgs.fetchurl {
      url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      # Let this run once and you will get the hash as an error.
      hash = "sha256-M3HdJQ5h2eFjNjAHP+/aFTzUQm9y9K+gwzc64uj+oDo=";
    };
  };
}
