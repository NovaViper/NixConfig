{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  features.vr = "wivrn";

  services.wivrn = {
    enable = true;
    openFirewall = true;
    config.enable = true;

    # Run WiVRn as a systemd service on startup
    autoStart = true;
  };

  hardware.graphics.extraPackages = with pkgs; [ monado-vulkan-layers ];

  environment.systemPackages = with pkgs; [ monado-vulkan-layers ];

  # From https://wiki.nixos.org/wiki/VR#Monado and https://wiki.nixos.org/wiki/VR#WiVRn
  hm.xdg.configFile."openxr/1/active_runtime.json".source =
    "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
  hm.xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "${hm-config.xdg.dataHome}/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "${hm-config.xdg.dataHome}/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.opencomposite}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';
}
