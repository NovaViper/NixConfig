{
  config,
  lib,
  pkgs,
  ...
}: {
  # Correct previous console command like "thefuck"
  programs.pay-respects.enable = true;
}
