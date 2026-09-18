{
  config,
  lib,
  myLib,
  pkgs,
  username,
  ...
}:
let
  hm-config = config.hm;
in
{
  imports = myLib.utils.importFeatures {
    boot = [
      "disko"
      "pretty-plymouth"
    ];
    desktop = lib.singleton "plasma6";
    # theme = lib.singleton "catppuccin";
    hardware = [
      "bluetooth"
      "hard-accel"
      "yubikey"
    ];
    apps = [
      # Defaults
      "browsers/firefox"
      "editors/neovim"
      "terminal/ghostty"

      # Decoration
      "cava"
      "fastfetch"

      "borgbackup"
      "discord"
      "gaming"
      "jellyfin"
      "keepassxc"
      "libreoffice"
      "pass"
      "topgrade"
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
      "behavior"
      "development"
      # "atuin"
      "oh-my-posh"
      "ux"
    ];
  };

  features = {
    hardware.apple.enable = true;
    development.enable = true;
  };

  hm.home.packages = with pkgs; [
    # 3D modeling and CAD
    openscad
    freecad-wayland

    # Imager
    kdePackages.isoimagewriter
    rpi-imager
    # Pinecil flashing
    blisp
    pineflash

    # Photography
    krita
    inkscape

    # Gaming
    vintagestory

    nerd-fonts.noto
    nerd-fonts._0xproto

    asciinema
    asciinema-agg
    webcamoid
    headsetcontrol
    easyeffects
  ];

  sopsHome.secrets."borg_token" = myLib.secrets.mkSecretFile {
    source = "borg-passkey";
    subDir = [
      "users"
      username
    ];
    destination = "${hm-config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
    format = "binary";
  };

  hm.programs.password-store.settings.PASSWORD_STORE_DIR =
    lib.mkForce "${hm-config.home.homeDirectory}/Sync/.password-store";
}
