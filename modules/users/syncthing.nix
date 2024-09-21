{
  outputs,
  config,
  pkgs,
  name,
  ...
}:
outputs.lib.mkModule config "syncthing" {
  nixos.services.syncthing = rec {
    user = outputs.lib.mkForce name;
    enable = true;
    dataDir = "/home/${name}/Sync";
    group = "users";
    configDir = "/home/${name}/.config/syncthing";
    openDefaultPorts = true;
  };

  home.packages = with pkgs; outputs.lib.mkIf (outputs.lib.isDesktop' config) [syncthingtray-minimal];
}
