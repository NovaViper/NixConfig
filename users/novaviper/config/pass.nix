{config, ...}: {
  hm.programs.password-store.settings.PASSWORD_STORE_DIR = "${config.hm.home.homeDirectory}/Sync/.password-store";
}
