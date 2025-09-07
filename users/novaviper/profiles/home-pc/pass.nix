{ config, ... }:
let
  hm-config = config.hm;
in
{
  hm.programs.password-store.settings.PASSWORD_STORE_DIR =
    "${hm-config.home.homeDirectory}/Sync/.password-store";
}
