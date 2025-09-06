{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  imports = myLib.utils.importFeatures "home" [
    ### Services
    "services/syncthing"

    ### Applications
    "apps/browser/brave"
    "apps/editor/neovim"
    "apps/terminal/ghostty"
    "apps/backup"
    "apps/discord"
    "apps/music-player"

    ### Terminal Utils
    "cli/history/atuin"
    "cli/prompt/oh-my-posh"
    "cli/deco"

    ### CLI
    "cli/dev"
    "cli/misc/topgrade"
  ];

  userVars = {
    defaultTerminal = "ghostty";
    defaultBrowser = "brave";
    defaultEditor = "neovim";
  };

  sops.secrets."borg_token" = myLib.secrets.mkSecretFile {
    source = "borg-passkey";
    subDir = [
      "users"
      "novaviper"
    ];
    destination = "${config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
    format = "binary";
  };

  home.packages = with pkgs; [
    openscad
    #freecad-wayland # TODO Add this back later.. takes way too long to
    #recompile and it's also broken anyway
    rpi-imager
    blisp
    libreoffice-qt6-fresh
    keepassxc
    #krita # TODO: Takes too long to recompile, add this back later
    kdePackages.tokodon
    smassh
    pineflash
    kdePackages.isoimagewriter
  ];
}
