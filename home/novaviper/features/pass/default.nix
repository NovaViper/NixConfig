{
  pkgs,
  config,
  ...
}: {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/Sync/.password-store";
    };
    package = pkgs.pass-wayland.withExtensions (p: with p; [pass-otp pass-audit pass-import pass-update pass-file pass-genphrase pass-checkup pass-tomb]);
  };
}
