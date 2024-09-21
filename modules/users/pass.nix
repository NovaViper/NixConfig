{
  config,
  outputs,
  pkgs,
  ...
}:
outputs.lib.mkDesktopModule config "password-store" {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = outputs.lib.mkDefault (throw "programs.password-store.settings.PASSWORD_STORE_DIR is not set");
    };
    package = pkgs.pass-wayland.withExtensions (p: with p; [pass-otp pass-audit pass-import pass-update pass-file pass-genphrase pass-checkup pass-tomb]);
  };
}
