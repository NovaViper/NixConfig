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
}:
{
  imports = lib.singleton inputs.home-manager.nixosModules.home-manager;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit
      self
      inputs
      stateVersion
      hostname
      primaryUser
      extraUsers
      allUsers
      myLib
      ;
  };
  home-manager.backupFileExtension = ".bak";

  home-manager.sharedModules =
    with inputs;
    [
      nix-index-database.homeModules.nix-index
      plasma-manager.homeManagerModules.plasma-manager
      (
        hm:
        let
          hm-config = hm.config;
        in
        {
          home = {
            inherit stateVersion;
            # REVIEW: Maybe implement this variable for hostVars?
            #homeDirectory = "${config.hostVars.homeBaseDirectory}/${hm-config.home.username}";
            sessionVariables.FLAKE = "${config.hostVars.configDirectory}";
            sessionVariables.NH_FLAKE = "${config.hostVars.configDirectory}";
          };

          #nix.settings = config.nix.settings;

          programs.home-manager.enable = true;

          # (De)activate wanted systemd units when changing configs
          systemd.user.startServices = "sd-switch";

          # Disable HTML help page
          manual.html.enable = lib.mkForce false;

          news.display = "silent";
        }
      )
    ]
    ++ self.homeModules.default;
}
