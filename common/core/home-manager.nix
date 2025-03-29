{
  config,
  lib,
  inputs,
  pkgs,
  stateVersion,
  ...
}: let
  hm-config = config.hm;
  user = config.userVars.username;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    # Let us use hm as shorthand for home-manager config
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" user])
  ];

  environment.systemPackages = with pkgs; [
    home-manager # Lets us run commands like `home-manager switch`
  ];

  hm = {
    programs.home-manager = {
      enable = true;
    };

    # NOTE: fixes https://github.com/danth/stylix/issues/865
    nixpkgs.overlays = lib.mkForce null;

    #nix.settings = config.nix.settings;

    # (De)activate wanted systemd units when changing configs
    systemd.user.startServices = "sd-switch";

    # Disable HTML help page
    manual.html.enable = lib.mkForce false;

    home = {
      inherit stateVersion;
      inherit (config.userVars) homeDirectory;
      username = user;

      preferXdgDirectories = true;

      sessionVariables.FLAKE = config.hostVars.configDirectory;

      sessionPath = ["${config.environment.sessionVariables.XDG_BIN_HOME}"];
    };
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = ".bak";
  home-manager.sharedModules = with inputs;
    [
      nix-index-database.hmModules.nix-index
      plasma-manager.homeManagerModules.plasma-manager
    ]
    ++ self.homeManagerModules.default;
}
