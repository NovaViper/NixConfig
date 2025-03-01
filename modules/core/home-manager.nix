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
}: let
  hm-config = config.hm;
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
in
  {
    imports = with inputs; [
      home-manager.nixosModules.home-manager
      # Let us use hm as shorthand for home-manager config
      (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])
      (lib.mkAliasOptionModule ["home"] ["hm" "home"])
      (lib.mkAliasOptionModule ["create" "configFile"] ["hm" "xdg" "configFile"])
      (lib.mkAliasOptionModule ["create" "dataFile"] ["hm" "xdg" "dataFile"])
    ];
  }
  // myLib.utilMods.mkEnabledModule config "core.homeManager" {
    # Home file nuking script that deletes stuff just before we run home-manager's activation scripts
    system.userActivationScripts.home-conflict-file-nuker = lib.mkIf (config.nukeFiles != []) activationScript;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit self inputs stateVersion hostname username;};
      backupFileExtension = ".bak";
      sharedModules = with inputs;
        [
          nix-index-database.hmModules.nix-index
          plasma-manager.homeManagerModules.plasma-manager
        ]
        ++ (builtins.attrValues self.outputs.homeManagerModules);
    };

    hm = {
      # NOTE: fixes https://github.com/danth/stylix/issues/865
      nixpkgs.overlays = lib.mkForce null;

      nix.settings = config.nix.settings;

      programs = {
        home-manager.enable = true;
        emacs.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        ssh.enable = lib.mkDefault true;
        gpg.enable = lib.mkDefault true;
      };

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
    };

    home = {
      inherit username stateVersion;
      inherit (config.variables.user) homeDirectory;
      preferXdgDirectories = true;

      sessionVariables = {
        FLAKE = "${hm-config.home.homeDirectory}/Documents/NixConfig";
      };
      sessionPath = ["${config.environment.sessionVariables.XDG_BIN_HOME}"];
    };
  }
