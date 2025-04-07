{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  myself = "novaviper";
in {
  imports = myLib.utils.importFeatures "features" [
    "apps/browser/floorp"
    "apps/editor/doom-emacs"
    #"apps/terminal/kitty"

    #"cli/dev"
    #"cli/misc/pass"
    #"cli/misc/topgrade"
  ];

  userVars.${myself} = {
    defaultTerminal = "kitty";
    defaultBrowser = "floorp";
    defaultEditor = "doom-emacs";
  };

  hmUser = lib.singleton (hm: let
    hm-config = hm.config;
  in {
    age.secrets."borg_token" = myLib.secrets.mkSecretFile {
      user = myself;
      source = "borg.age";
      destination = "${hm-config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
    };

    home.packages = with pkgs; [openscad freecad rpi-imager blisp libreoffice-qt6-fresh keepassxc krita kdePackages.tokodon smassh pineflash klipper-estimator];
  });
}
