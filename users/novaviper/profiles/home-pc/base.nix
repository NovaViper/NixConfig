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
    ### Applications
    "programs/browser/brave"
    "programs/neovim"
    "programs/ghostty"
    "programs/keepassxc"

    ### Terminal Utils
    #"cli/atuin"
    "cli/oh-my-posh"
    "cli/deco"

    ### CLI
    "cli/dev"
    "cli/misc/pass"
    "cli/misc/topgrade"
  ];

  hm.userVars = {
    defaultTerminal = "ghostty";
    defaultBrowser = "brave";
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
    libreoffice-qt6-fresh
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
