{
  pkgs,
  config,
  ...
}: {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "$HOME/Sync/.password-store";
    };
    package = pkgs.pass-wayland.withExtensions (p: [p.pass-otp p.pass-audit p.pass-import p.pass-update p.pass-file p.pass-genphrase p.pass-checkup p.pass-tomb]);
  };

  services.pass-secret-service = {
    enable = true;
    storePath = "${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
  };
}
