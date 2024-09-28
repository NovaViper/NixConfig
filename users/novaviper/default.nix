{
  config,
  osConfig,
  inputs,
  outputs,
  system,
  hostname,
  name,
  pkgs,
  ...
}: let
  #ifIsDesktop = outputs.lib.optionals (outputs.lib.isDesktop config hostname);
  agenixHashedPasswordFile = outputs.lib.optionalString (outputs.lib.hasAttr "agenix" inputs) osConfig.age.secrets."${name}-password".path;
in
  outputs.lib.mkFor system hostname {
    common = {
      imports =
        outputs.lib.umport {path = ../../modules/users;}
        ++ outputs.lib.umport {path = ./config;};

      fullName = "Nova Leary";
      emailAddress = "coder.nova99@mailbox.org";

      defaultTerminal = "kitty";
      defaultBrowser = "floorp";
      modules = outputs.lib.enable [
        "git"
        "ssh"
        "gpg"
        "yubikey"
        "doom-emacs"
        "age"
        "password-store"

        # Terminal
        "zsh"
        "shell-utils"
        "nix"
        "cava"
        "tmux"
        "bat"
        "btop"
        "fastfetch"
        "topgrade"
      ];
    };

    systems = {
      linux = {
        modules = outputs.lib.enable [
          "vivaldi"
          "plasma6"
          "fonts"
          # Apps
          "jellyfin-player"
          "borg"
          "discord"
          "syncthing"

          # Terminal

          # Development Environment
          "latex"
          "lua"
          "markdown"
          "python"
        ];

        wallpaper = "${inputs.wallpapers}/purple-mountains-ai.png";

        nixos = {
          # Make CAPS LOCK become CTRL key for Emacs
          services.xserver.xkb.options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";

          # User Secrets
          age.secrets."${name}-password" = outputs.lib.mkSecretFile {
            user = name;
            source = "passwd.age";
            owner = name;
            group = "users";
          };

          users.users."${name}" = {
            isNormalUser = true;
            description = "${config.fullName}";
            shell = pkgs.zsh;
            extraGroups = [
              "networkmanager"
              "wheel"
              "video"
              "audio"
              "libvirtd"
              "scanner"
              "i2c"
              "git"
              "gamemode"
            ];
            hashedPasswordFile = agenixHashedPasswordFile;
          };
        };
      };
    };

    hosts = {
      ryzennova = {
        isDesktop = true;

        modules = outputs.lib.enable ["gaming" "steam" "minecraft" "vr" "obs-studio"];
        nixos = {
          programs.localsend.enable = true;

          system.activationScripts.makeOpenRGBSettings = ''
            mkdir -p /var/lib/OpenRGB/plugins/settings/effect-profiles
            cp ${./dotfiles/openrgb/rgb-devices.json} /var/lib/OpenRGB/OpenRGB.json
          '';
        };
        xdg.configFile = {
          "OpenRGB/plugins/settings/effect-profiles/default".source = outputs.lib.getDotsPath {
            user = name;
            path = "openrgb/rgb-default-effect.json";
          };
          "OpenRGB/plugins/settings/EffectSettings.json".source = outputs.lib.getDotsPath {
            user = name;
            path = "openrgb/rgb-effect-settings.json";
          };
        };

        programs.rio.settings.window = {
          width = 1000;
          height = 600;
        };
      };

      yoganova = {
        isDesktop = true;
        modules = outputs.lib.enable ["gaming" "steam" "minecraft"];
        nixos = {
          programs.localsend.enable = true;

          # Apply configs
          system.activationScripts.copySysConfigs = ''
            mkdir -p /var/lib/linux-enable-ir-emitter
            if [ -z "$(ls -A /var/lib/linux-enable-ir-emitter)" ]; then
               cp ${builtins.readFile ./dotfiles/faceid/ir-emitter-driver.txt} /var/lib/linux-enable-ir-emitter/pci-0000:00:14.0-usb-0:6:1.2-video-index0_emitter0.driver
            fi
          '';
        };

        programs.rio.settings.window = {
          width = 1200;
          height = 800;
        };

        home.packages = with pkgs; [moonlight-qt];
      };
    };
  }
