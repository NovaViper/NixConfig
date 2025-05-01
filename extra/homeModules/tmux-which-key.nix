{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tmux.which-key;
  rtpPath = "tmux/plugins/tmux-which-key";
in
{
  options.programs.tmux.which-key = {
    enable = lib.mkEnableOption "tmux-which-key";
    package = lib.mkPackageOption pkgs [ "tmuxPlugins" "tmux-which-key" ] { };
    settings = lib.mkOption {
      type =
        with lib.types;
        let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "tmux-which-key configuration value";
            };
        in
        valueType;
      default =
        let
          fromYaml =
            file:
            let
              convertedJson =
                pkgs.runCommandNoCC "config.json"
                  {
                    nativeBuildInputs = [ pkgs.yj ];
                  }
                  ''
                    ${lib.getExe pkgs.yj} < ${file} > $out
                  '';
            in
            builtins.fromJSON (builtins.readFile "${convertedJson}");
        in
        fromYaml "${cfg.package}/share/tmux-plugins/tmux-which-key/config.example.yaml";
    };
  };

  config =
    let
      configYaml = lib.generators.toYAML { } cfg.settings;
      configTmux =
        pkgs.runCommandNoCC "init.tmux"
          {
            nativeBuildInputs = cfg.package.buildInputs;
          }
          ''
            set -x
            echo '${configYaml}' > config.yaml
            ${lib.getExe pkgs.python3} "${cfg.package}/share/tmux-plugins/tmux-which-key/plugin/build.py" \
              config.yaml $out
          '';
    in
    lib.mkIf cfg.enable {
      xdg = {
        #configFile."${rtpPath}/config.yaml".text = configYaml; # Refernece
        dataFile."${rtpPath}/init.tmux".source = configTmux; # The actual file being used
      };
      programs.tmux.plugins = [
        {
          plugin = cfg.package;
          extraConfig = ''
            set -g @tmux-which-key-xdg-enable 1;
            set -g @tmux-which-key-disable-autobuild 1
            set -g @tmux-which-key-xdg-plugin-path "${rtpPath}"
          '';
        }
      ];
    };
}
