_: {
  # Correct previous console command like "thefuck"
  hm.programs.pay-respects.enable = true;

  # Replaced with pay-respects
  hm.programs.command-not-found.enable = false;

  # Let pay-respects handle this
  hm.programs.nix-index.enableBashIntegration = false;
  hm.programs.nix-index.enableZshIntegration = false;
  hm.programs.nix-index.enableFishIntegration = false;
}
