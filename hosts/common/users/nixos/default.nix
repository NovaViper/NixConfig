{
  config,
  lib,
  pkgs,
  ...
}: {
  variables.username = "nixos";

  users.users.nixos = {
    shell = pkgs.zsh;
    packages = with pkgs; [home-manager];
  };

  home-manager.users.nixos = import ../../../../home/nixos/image.nix;

  # Make hardware clock use localtime.
  time.timeZone = lib.mkDefault "UTC";

  # Setup automatic timezone detection
  services.automatic-timezoned.enable = true;
  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
  };
}
