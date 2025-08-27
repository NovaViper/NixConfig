{
  config,
  lib,
  pkgs,
  ...
}:
{
  features.vr = "wivrn";

  services.wivrn = {
    enable = true;
    openFirewall = true;
    config.enable = true;

    # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
    # will automatically read this and work with WiVRn (Note: This does not currently
    # apply for games run in Valve's Proton)
    defaultRuntime = true;

    # Run WiVRn as a systemd service on startup
    autoStart = true;
  };

  hardware.graphics.extraPackages = with pkgs; [ monado-vulkan-layers ];

  environment.systemPackages = with pkgs; [ monado-vulkan-layers ];

  # From https://wiki.nixos.org/wiki/VR#Monado and https://wiki.nixos.org/wiki/VR#WiVRn
  home-manager.sharedModules = lib.singleton (
    hm:
    let
      hm-config = hm.config;
    in
    {
      xdg.configFile."openxr/1/active_runtime.json".source =
        "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
      xdg.configFile."openvr/openvrpaths.vrpath".text = ''
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
  );
}
