{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
in {
  imports = myLib.utils.importFeatures "features/home" [
    "apps/browser/floorp"
    "apps/editor/doom-emacs"
    "apps/terminal/kitty"
    "apps/backup"
    "apps/discord"

    "cli/dev"
    "cli/misc/pass"
    "cli/misc/topgrade"
  ];

  userVars = {
    defaultTerminal = "kitty";
    defaultBrowser = "floorp";
    defaultEditor = "doom-emacs";
  };

  hm.age.secrets."borg_token" = myLib.secrets.mkSecretFile {
    user = myself;
    source = "borg.age";
    destination = "${hm-config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
  };

  hm.home.packages = with pkgs; [openscad freecad rpi-imager blisp libreoffice-qt6-fresh keepassxc krita kdePackages.tokodon smassh pineflash klipper-estimator];
}
