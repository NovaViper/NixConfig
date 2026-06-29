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
  imports = myLib.utils.importFeatures {
    boot = [
      "disko"
      "pretty-plymouth"
    ];
    desktop = lib.singleton "plasma6";
    theme = lib.singleton "catppuccin";
    hardware = [
      "bluetooth"
      "hard-accel"
      "yubikey"
    ];
    apps = [
      "browsers/firefox"
      "borgbackup"
      "discord"
      "gaming"
      "jellyfin"
      "libreoffice"
      "neovim"
      "ghostty"
      "keepassxc"
    ];
    services = [
      "gps"
      "localsend"
      "packaging"
      "printing"
      "syncthing"
      "tailscale"
    ];
    cli = [
      "development"
      "pass"
      "topgrade"
      # "atuin"
      "oh-my-posh"
      # Decoration
      "cava"
      "fastfetch"
    ];
  };

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
