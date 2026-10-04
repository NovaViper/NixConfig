{
  config,
  lib,
  pkgs,
  ...
}:
let
  # tesseractLanguages = [
  #   "eng"
  # ]
  # ++ lib.optionals (isFull) [
  #   "deu"
  #   "fra"
  #   "ita"
  #   "spa"
  # ];
in
{
  environment.systemPackages = with pkgs; [
    # Utilities/Libraries
    ddcutil

    # Basic Editor
    zed-editor

    # grim # for flameshot
    # File Manager
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.ark

    # Misc Apps
    qalculate-gtk

    kdePackages.okular

    # Screenshoot handling
    grim
    slurp
    # Color picker
    hyprpicker
  ];

  hm.programs.numbat.enable = true;

  # Needed for various stuff
  hm.programs.mpv.enable = true;

  # hm.services.flameshot = {
  #   enable = true;
  #   settings.General = {
  #     # disabledGrimWarning = true;
  #     # useGrimAdapter = true; # Requires grim!
  #   };
  # };
  hm.xdg.mimeApps = {
    defaultApplications = {
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
      "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
    };
    associations.added."x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
  };

  # Enable kdeconnect service
  hm.services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Add kdeconnect ports
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
