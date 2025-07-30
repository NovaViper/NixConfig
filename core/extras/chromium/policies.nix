{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  # Enable only when we're using a desktop environment
  programs.chromium.enable = if (config.features.desktop != null) then true else false;

  programs.chromium.extraOpts = {
    # Brave related
    BraveRewardsDisabled = true;
    BraveWalletDisabled = true;
    BraveVPNDisabled = true;
    #BraveAIChatEnabled = false;

    PasswordManagerEnabled = false;
    PasswordSharingEnabled = false;
    PasswordLeakDetectionEnabled = false;

    MetricsReportingEnabled = false;
  };
}
