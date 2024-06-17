{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [moonlight-qt];

  # https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/advanced_usage.html#port
  networking.firewall = {
    allowedTCPPorts = [47984 47989 47990 48010];
    allowedUDPPorts = [47998 47999 48000 48002];
  };
}
