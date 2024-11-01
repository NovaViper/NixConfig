{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "password-store" {
  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = lib.mkDefault (throw "programs.password-store.settings.PASSWORD_STORE_DIR is not set");
  };

  programs.password-store.package = pkgs.pass-wayland.withExtensions (p: with p; [pass-otp pass-audit pass-import pass-update pass-file pass-genphrase pass-checkup pass-tomb]);
}