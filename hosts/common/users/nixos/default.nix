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
    # TODO: Until NixOS/nixpkgs/issues/293964 is fixed, add temporary password for live-image user.
    initialPassword = lib.mkForce "nixos";
    initialHashedPassword = lib.mkForce null;
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
