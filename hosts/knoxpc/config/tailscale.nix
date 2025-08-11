{
  config,
  lib,
  myLib,
  ...
}:
{
  sops.secrets."tailscale-authkey" = myLib.secrets.mkSecretFile {
    source = "secrets.yaml";
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
  };

  services.tailscale = {
    openFirewall = true;
    authKeyFile = config.sops.secrets."tailscale-authkey".path;
    extraUpFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.1.0/24"
    ];
    useRoutingFeatures = lib.mkForce "server";
  };
}
