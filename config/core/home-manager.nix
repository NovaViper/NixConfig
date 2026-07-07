{
  config,
  lib,
  myLib,
  pkgs,
  self,
  inputs,
  stateVersion,
  hostname,
  username,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    # Let us use hm as shorthand for home-manager config
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" username ])
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
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
  # Backup existing files with a timestamp to avoid backup name collisions.
  home-manager.backupCommand = pkgs.writeShellScript "hm-backup-command" ''
    target="$1"
    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup_path="''${target}.hm-backup-''${timestamp}"

    if [ -e "''${backup_path}" ]; then
      backup_path="''${backup_path}-$$"
        fi

        mv -- "''${target}" "''${backup_path}"
  '';

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
      sessionVariables.FLAKE = "${config.vars.host.configDirectory}";
      sessionVariables.NH_FLAKE = "${config.vars.host.configDirectory}";
    };

    #nix.settings = config.nix.settings;

    programs.home-manager.enable = true;

    # (De)activate wanted systemd units when changing configs
    systemd.user.startServices = "sd-switch";

    # Disable HTML help page
    manual.html.enable = lib.mkForce false;
  };
}
