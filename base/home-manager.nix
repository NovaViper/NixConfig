{
  config,
  lib,
  myLib,
  self,
  inputs,
  stateVersion,
  hostname,
  username,
  ...
}:
let
  hm-config = config.hm;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    # Let us use hm as shorthand for home-manager config
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" username ])
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".bak";
  home-manager.extraSpecialArgs = {
    inherit
      self
      inputs
      stateVersion
      hostname
      username
      myLib
      ;
  };

  home-manager.sharedModules =
    with inputs;
    [
      nix-index-database.homeModules.nix-index
      plasma-manager.homeModules.plasma-manager
    ]
    ++ self.homeModules.default;

  hm = {

    home = {
      inherit stateVersion;
      # REVIEW: Maybe implement this variable for hostVars?
      #homeDirectory = "${config.hostVars.homeBaseDirectory}/${username}";
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
  };
}
