{
  config,
  lib,
  myLib,
  self,
  inputs,
  stateVersion,
  hostname,
  primaryUser,
  extraUsers,
  allUsers,
  ...
}: {
  imports = lib.singleton inputs.home-manager.nixosModules.home-manager;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {inherit self inputs stateVersion hostname primaryUser extraUsers allUsers myLib;};
  home-manager.backupFileExtension = ".bak";

  home-manager.sharedModules = with inputs;
    [
      nix-index-database.hmModules.nix-index
      plasma-manager.homeManagerModules.plasma-manager
      (hm: let
        hm-config = hm.config;
      in {
        home = {
          inherit stateVersion;
          # REVIEW: Maybe implement this variable for hostVars?
          #homeDirectory = "${config.hostVars.homeBaseDirectory}/${hm-config.home.username}";
          preferXdgDirectories = true;

          sessionVariables.FLAKE = "${config.hostVars.configDirectory}";
          sessionPath = ["${config.environment.sessionVariables.XDG_BIN_HOME}"];
        };

        #nix.settings = config.nix.settings;

        programs.home-manager.enable = true;

        # (De)activate wanted systemd units when changing configs
        systemd.user.startServices = "sd-switch";

        # Disable HTML help page
        manual.html.enable = lib.mkForce false;

        news.display = "silent";

        # Make sure XDG is enabled
        xdg.enable = true;

        xresources.path = lib.mkForce "${hm-config.xdg.configHome}/.Xresources";

        gtk = {
          enable = true;
          gtk2.configLocation = lib.mkForce "${hm-config.xdg.configHome}/gtk-2.0/gtkrc";
        };
      })
    ]
    ++ self.homeModules.default;
}
