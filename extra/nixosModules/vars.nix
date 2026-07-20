{
  lib,
  config,
  options,
  username,
  ...
}:
let
  cfg = config.vars;
  cfgFeat = config.features;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.vars = {
    user = {
      fullName = mkOption {
        type = types.str;
        description = "Your first and last name";
        default = "";
      };
      email = mkOption {
        type = types.str;
        description = "Your email address";
        default = "";
      };
    };
    desktop = {
      profile = mkOption {
        type = types.nullOr (
          types.enum [
            "full"
            "minimal"
          ]
        );
        description = "What desktop profile to use. 'full' will install a full desktop environment, while 'minimal' will only install the bare minimum for a desktop.";
        default = null;
      };
    };

    apps = {
      terminal = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The preferred terminal app";
          default = null;
        };
        desktopFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = ''
            The .desktop file ID of the preferred terminal emulator.
            This is the reverse-DNS identifier used by XDG MIME and desktop launchers,
            which often differs from the binary name
            (e.g. "com.mitchellh.ghostty", not "ghostty").
            Set automatically by the imported terminal module via lib.mkDefault.
          '';
          default = null;
        };
      };
      browser = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The preferred internet browser app";
          default = null;
        };
        # desktopFile = lib.mkOption {
        #   type = lib.types.nullOr lib.types.str;
        #   description = ''
        #     The .desktop file ID of the preferred browser.
        #     This is the reverse-DNS identifier used by XDG MIME and desktop launchers,
        #     which often differs from the binary name
        #     (e.g. "org.mozilla.firefox", not "firefox").
        #     Set automatically by the imported browser module via lib.mkDefault.
        #   '';
        #   default = null;
        # };
      };
      editor = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The preferred text editor app";
          default = null;
        };
        desktopFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = ''
            The .desktop file ID of the preferred editor.
            May differ from the editor name � neovim's GUI wrapper is "neovide",
            and doom-emacs launches as "emacsclient".
            Set automatically by the imported editor module via lib.mkDefault.
          '';
          default = null;
        };
      };
    };

    host = {
      configDirectory = lib.mkOption {
        type = types.str;
        description = "The directory of the local nixos configuration.";
        default = null;
      };
      scalingFactor = mkOption {
        type = types.number;
        description = "The scaling factor for the desktop. A scalingFactor of 1 --> 100% scaling.";
        default = 1;
      };
    };
  };

  config.assertions = [
    { assertion = cfg.host.configDirectory != null; }
    { assertion = cfg.host.scalingFactor != null; }
    {
      assertion = (cfgFeat.desktop.type != null) -> (cfg.apps.terminal.name != null);
      message = ''
        features.desktop.type is set but vars.apps.terminal is null.
        Import a terminal module (e.g. "terminal/ghostty") or set vars.apps.terminal explicitly.
      '';
    }
    {
      assertion = (cfgFeat.desktop.type != null) -> (cfg.apps.browser.name != null);
      message = ''
        features.desktop.type is set but vars.apps.browser is null.
        Import a browser module (e.g. "browsers/firefox") or set vars.apps.browser explicitly.
      '';
    }
    {
      assertion = (cfgFeat.desktop.type != null) -> (cfg.apps.editor.name != null);
      message = ''
        features.desktop.type is set but vars.apps.editor is null.
        Import a editor module (e.g. "editors/neovim") or set vars.apps.editor explicitly.
      '';
    }
    {
      assertion = config.vars.desktop.profile == null || cfgFeat.desktop.type != null;

      message = "vars.desktop.profile requires features.desktop.type to be set.";
    }

    {
      assertion = cfgFeat.desktop.type == null || config.vars.desktop.profile != null;

      message = "features.desktop.type requires vars.desktop.profile to be set.";
    }
  ];
}
