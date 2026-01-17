{
  config,
  lib,
  myLib,
  inputs,
  ...
}:
let
  interfaces = [ "wlp2s0" ];
in
{
  sops.secrets."server_networks" = myLib.secrets.mkSecretFile {
    source = "networks.env";
    format = "dotenv";
    owner = "wpa_supplicant";
    group = "wpa_supplicant";
    restartUnits = map (id: "wpa_supplicant-${id}.service") interfaces;
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
  };

  networking.wireless.enable = true;

  networking.wireless.interfaces = interfaces;

  networking.wireless.secretsFile = config.sops.secrets."server_networks".path;

  networking.wireless.networks."${inputs.nix-secrets.networking.home-ssid}" = {
    pskRaw = "ext:home_pskRaw";
    authProtocols = [ "WPA-PSK" ];
  };
}
