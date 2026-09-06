{
  config,
  lib,
  myLib,
  inputs,
  ...
}:
let
  interfaces = [ "wlp4s0" ];
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
  # Static IPv4 configuration
  networking.interfaces.wlp4s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.120";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "wlp4s0";
  };
  networking.nameservers = [
    "192.168.1.1"
    "1.1.1.1"
  ];
}
