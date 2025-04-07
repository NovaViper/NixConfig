{
  config,
  lib,
  myLib,
  self,
  inputs,
  stateVersion,
  hostname,
  users,
  ...
}: let
  activationScript = let
    commands = builtins.concatStringsSep "\n" (
      map (file: ''rm -fv "${file}" && echo Deleted "${file}"'') config.nukeFiles
    );
  in ''
    #!/run/current-system/sw/bin/bash
    set -o errexit
    set -o nounset

    echo "[home-nuker] Nuking files so Home Manager can get its will"

    ${commands}
  '';
in {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
    # Let us use hm as shorthand for home-manager config
    #(lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])
    (lib.mkAliasOptionModule ["hmShared"] ["home-manager" "sharedModules"])
  ];

  # Home file nuking script that deletes stuff just before we run home-manager's activation scripts
  system.userActivationScripts.home-conflict-file-nuker = lib.mkIf (config.nukeFiles != []) activationScript;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit self inputs stateVersion hostname users myLib;};
    backupFileExtension = ".bak";
    sharedModules = with inputs;
      [
        nix-index-database.hmModules.nix-index
        plasma-manager.homeManagerModules.plasma-manager
      ]
      ++ self.homeModules.default;
  };

  /*
    hmUser = lib.singleton (hm: let
    hm-config = hm.config;
  in {
  */
  hmShared = lib.singleton (hm: let
    hm-config = hm.config;
  in {
    home = {
      inherit stateVersion;
      # REVIEW: Look at changing this maybe?
      #inherit (config.userVars.user) homeDirectory;
      preferXdgDirectories = true;

      sessionVariables = {
        FLAKE = "${config.hostVars.configDirectory}";
      };
      sessionPath = ["${config.environment.sessionVariables.XDG_BIN_HOME}"];
    };

    # NOTE: fixes https://github.com/danth/stylix/issues/865
    nixpkgs.overlays = lib.mkForce null;

    #nix.settings = config.nix.settings;

    programs.home-manager.enable = true;

    # (De)activate wanted systemd units when changing configs
    systemd.user.startServices = "sd-switch";

    # Disable HTML help page
    manual.html.enable = lib.mkForce false;

    news.display = "silent";
  });
}
