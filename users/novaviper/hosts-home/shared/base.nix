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
    freecad
    rpi-imager
    blisp
    libreoffice-qt6-fresh
    keepassxc
    krita
    kdePackages.tokodon
    smassh
    pineflash
    kdePackages.isoimagewriter
  ];
}
