{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.password-store.settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/Sync/.password-store";
}
