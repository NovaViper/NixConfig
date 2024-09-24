{pkgs, ...}: {
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [nur.repos.ataraxiasjel.waydroid-script];
}
