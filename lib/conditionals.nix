{outputs, ...}:
with outputs.lib; {
  isLinux = hasSuffix "linux";
  #isDarwin = hasSuffix "darwin";

  isWayland = config: config.home.sessionVariables ? NIXOS_OZONE_WL;
  isDesktop = osConfig: hostname: isWayland osConfig || outputs.nixosConfigurations."${hostname}".config.services.xserver.enable;
  isDesktop' = hmConfig: hmConfig.isDesktop || isWayland hmConfig || (hmConfig.nixos ? services && hmConfig.nixos.services.xserver.enable);

  mkFor = system: hostname: {
    common ? {},
    systems ? {},
    hosts ? {},
  }: let
    systemConfig =
      if isLinux system && systems ? "linux"
      then systems.linux
      #else if isDarwin system && systems ? "darwin" then
      #  systems.darwin
      else {};
    hostConfig =
      if hostname != null && hosts ? ${hostname}
      then hosts.${hostname}
      else {};
  in
    deepMerge [common systemConfig hostConfig];
}
