{
  pkgs,
  config,
  outputs,
  name,
  system,
  hostname,
  stateVersion,
  osConfig,
  ...
}:
with outputs.lib;
  mkFor system hostname {
    common = {
      home = {
        username = mkDefault name;
        stateVersion = mkDefault stateVersion;

        sessionVariables = {
          FLAKE = "${config.home.homeDirectory}/Documents/NixConfig";
          XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";

          ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
          CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
          TLDR_CACHE_DIR = "${config.xdg.cacheHome}/tldr";
        };
        sessionPath = ["${config.home.sessionVariables.XDG_BIN_HOME}"];
        shellAliases = {
          wget = ''wget --hsts-file="${config.xdg.dataHome}/wget-hsts"'';
        };
      };

      xresources.path = mkForce "${config.xdg.configHome}/.Xresources";

      gtk = {
        enable = true;
        gtk2.configLocation = mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";
      };

      programs = {
        emacs.enable = mkDefault true;
        git.enable = mkDefault true;
        ssh.enable = mkDefault true;
        gpg.enable = mkDefault true;

        # Only needed on non-NixOS systems, also see `mkUser` in `lib/users.nix`.
        # https://github.com/nix-community/home-manager/blob/ca4126e3c568be23a0981c4d69aed078486c5fce/nixos/common.nix#L18
        home-manager.enable = mkDefault (osConfig == null);
      };

      # Enable HTML help page
      manual.html.enable = true;

      news.display = "silent";

      # Import nixpkgs and nix config into default path for nix shell commands
      nix.settings = import ../nix/nix-config.nix;

      # Make sure XDG is enabled
      xdg.enable = true;
      xdg.configFile."nixpkgs/config.nix".source = ../nix/nixpkgs-config.nix;
    };

    systems = {
      linux = {
        home.homeDirectory = mkDefault "/home/${name}";

        # (De)activate wanted systemd units when changing configs
        systemd.user.startServices = "sd-switch";
      };
      #darwin.home.homeDirectory = mkDefault "/Users/${name}";
    };
  }
