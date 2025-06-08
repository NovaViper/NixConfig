{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Correct previous console command like "thefuck"
  programs.pay-respects.enable = true;

  # Replaced with pay-respects
  programs.command-not-found.enable = false;

  # Let pay-respects handle this
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;
  programs.nix-index.enableFishIntegration = false;
}
