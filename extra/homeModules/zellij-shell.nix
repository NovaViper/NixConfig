{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.zellij;
  mkShellIntegrationOption =
    option:
    option
    // {
      default = false;
      example = true;
    };
in
{
  options = {
    programs.zellij = {
      overrideIntegration = lib.mkEnableOption "Override shell integration";
      overrides = {
        enableBashIntegration = mkShellIntegrationOption (
          lib.hm.shell.mkBashIntegrationOption { inherit config; }
        );

        enableFishIntegration = mkShellIntegrationOption (
          lib.hm.shell.mkFishIntegrationOption { inherit config; }
        );

        enableZshIntegration = mkShellIntegrationOption (
          lib.hm.shell.mkZshIntegrationOption { inherit config; }
        );
      };
    };
  };

  config =
    let
      overrideCfg = cfg.overrides;
      zellijExe = lib.getExe cfg.package;
    in
    lib.mkIf cfg.enable {
      # Forcibly disable original shell integration
      programs.zellij = lib.mkIf cfg.overrideIntegration {
        enableFishIntegration = lib.mkForce false;
        enableZshIntegration = lib.mkForce false;
        enableBashIntegration = lib.mkForce false;
      };
      home.sessionVariables = lib.mkIf cfg.overrideIntegration {
        ZELLIJ_AUTO_ATTACH = if cfg.attachExistingSession then "true" else "false";
        ZELLIJ_AUTO_EXIT = if cfg.exitShellOnExit then "true" else "false";
      };

      programs.bash.initExtra = lib.mkIf overrideCfg.enableBashIntegration ''
        if [[ -z "$ZELLIJ" ]] &&
          [[ -z "$TMUX" ]] &&
          [[ -z "$SSH_CONNECTION" ]] &&
          [[ -z "$SSH_CLIENT" ]] &&
          [[ -z "$SSH_TTY" ]] &&
          [[ -z "$IN_NIX_SHELL" ]]; then

          if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            ${zellijExe} attach -c
          else
            ${zellijExe}
          fi

          if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
            exit
          fi
        fi
      '';

      programs.zsh.initContent = lib.mkIf overrideCfg.enableZshIntegration (
        lib.mkOrder 200 ''
          if [[ -z "$ZELLIJ" &&
              -z "$TMUX" &&
              -z "$SSH_CONNECTION" &&
              -z "$SSH_CLIENT" &&
              -z "$SSH_TTY" &&
              -z "$IN_NIX_SHELL" ]]; then

            if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
                ${zellijExe} attach -c
            else
                ${zellijExe}
            fi

            if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
                exit
            fi
          fi
        ''
      );

      programs.fish.interactiveShellInit = lib.mkIf overrideCfg.enableFishIntegration ''
        if not set -q ZELLIJ;
            and not set -q TMUX;
            and not set -q SSH_CONNECTION;
            and not set -q SSH_CLIENT;
            and not set -q SSH_TTY;
            and not set -q IN_NIX_SHELL

            if test "$ZELLIJ_AUTO_ATTACH" = "true"
                ${zellijExe} attach -c
            else
                ${zellijExe}
            end

            if test "$ZELLIJ_AUTO_EXIT" = "true"
                kill $fish_pid
            end
        end
      '';
    };
}
