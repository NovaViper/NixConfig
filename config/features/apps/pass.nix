{
  lib,
  pkgs,
  ...
}:
{
  hm.programs.password-store = {
    enable = true;
  };

  hm.home.packages = with pkgs; [ qtpass ];

  hm.programs.password-store.package = pkgs.gopass;

  # hm.programs.password-store.package = pkgs.pass.withExtensions (
  #   p: with p; [
  #     pass-otp
  #     pass-audit
  #     pass-import
  #     pass-update
  #     pass-file
  #     pass-genphrase
  #     pass-checkup
  #     pass-tomb
  #   ]
  # );
}
