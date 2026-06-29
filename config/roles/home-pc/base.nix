{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  myself = "novaviper";
  hm-config = config.hm;
in
{
  imports = myLib.utils.importFeatures [
    ### Boot
    "boot/pretty-plymouth"
    "boot/disko"

    ### Theme
    #"theme/dracula"
    "theme/catppuccin"

    ### Hardware
    "hardware/bluetooth"
    "hardware/hard-accel"
    "hardware/yubikey"

    ### Service
    "services/gps"
    "services/localsend"
    "services/packaging"
    "services/printing"
    "services/syncthing"
    "services/tailscale"

    ### Desktop Environment
    "desktop/plasma6"

    ### Applications
    "apps/browsers/firefox"
    "apps/borgbackup"
    "apps/discord"
    "apps/gaming"
    "apps/jellyfin"
    "apps/libreoffice"
    "apps/neovim"
    "apps/ghostty"
    "apps/keepassxc"

    ### Terminal Utils
    #"cli/atuin"
    "cli/oh-my-posh"
    "cli/cava"
    "cli/fastfetch"

    ### CLI
    "cli/development"
    "cli/pass"
    "cli/topgrade"
  ];

  hm.userVars = {
    defaultTerminal = "ghostty";
    defaultBrowser = "firefox";
    defaultEditor = "neovim";
  };

  sopsHome.secrets."borg_token" = myLib.secrets.mkSecretFile {
    source = "borg-passkey";
    subDir = [
      "users"
      myself
    ];
    destination = "${hm-config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
    format = "binary";
  };

  hm.home.packages = with pkgs; [
    openscad
    freecad-wayland
    rpi-imager
    blisp
    krita
    kdePackages.tokodon
    smassh
    pineflash
    kdePackages.isoimagewriter
    vintagestory
    inkscape
    asciinema
    asciinema-agg
  ];
}
