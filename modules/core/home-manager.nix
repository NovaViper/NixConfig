{
  config,
  lib,
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
      map (file: ''rm -fv "${file}" && echo Deleted "${file}"'') hm-config.nukeFiles
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
    ];
  }
  // lib.utilMods.mkEnabledModule config "core.homeManager" {
    # Home file nuking script that deletes stuff just before we run home-manager's activation scripts
    system.userActivationScripts.home-conflict-file-nuker = lib.mkIf (hm-config.nukeFiles != []) activationScript;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit self inputs stateVersion hostname username;};
      backupFileExtension = ".bak";
      sharedModules = with inputs;
        [
          nix-index-database.hmModules.nix-index
          plasma-manager.homeManagerModules.plasma-manager
          #stylix.homeManagerModules.stylix
        ]
        # Import modules specific and user configs for home-manager
        # TODO: Maybe make ./config in users be available to NixOS too and just pass any Home-Manager configs via hm?
        ++ lib.utils.concatImports {
          paths = [
            ../home
            (lib.fileset.maybeMissing ../../users/${username}/config)
          ];
        };
    };

    hm = {
      nix.settings = config.nix.settings;

      programs = {
        home-manager.enable = true;
        emacs.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        ssh.enable = lib.mkDefault true;
        gpg.enable = lib.mkDefault true;
      };

      home = {
        inherit username stateVersion;
        inherit (config.variables.user) homeDirectory;
        preferXdgDirectories = true;

        sessionVariables = {
          FLAKE = "${hm-config.home.homeDirectory}/Documents/NixConfig";
          XDG_BIN_HOME = "${hm-config.home.homeDirectory}/.local/bin";

          ANDROID_USER_HOME = "${hm-config.xdg.dataHome}/android";
          CUDA_CACHE_PATH = "${hm-config.xdg.cacheHome}/nv";
          TLDR_CACHE_DIR = "${hm-config.xdg.cacheHome}/tldr";
        };
        sessionPath = ["${hm-config.home.sessionVariables.XDG_BIN_HOME}"];
        shellAliases.wget = ''wget --hsts-file="${hm-config.xdg.dataHome}/wget-hsts"'';
      };

      # (De)activate wanted systemd units when changing configs
      systemd.user.startServices = "sd-switch";

      # Enable HTML help page
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
  }
