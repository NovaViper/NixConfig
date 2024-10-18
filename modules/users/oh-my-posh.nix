{
  outputs,
  config,
  pkgs,
  ...
}: let
  # Pass unicode symbols correctly
  ucode = code: builtins.fromJSON "\"\\u${code}\"";

  mkSeg' = {
    type,
    style,
    opts,
  }:
    {inherit type style;} // opts;

  # Make a plain segment
  mkSeg = type: opts:
    mkSeg' {
      inherit type opts;
      style = "plain";
    };

  # Make a Powerline segment that's on the corner of the screen
  mkPowerlineSegCorner = type: opts:
    mkSeg' {
      inherit type opts;
      style = "powerline";
    };

  # Make a powerline segment that has the arrows (for left side)
  mkPowerlineSeg = type: opts:
    mkSeg' {
      inherit type;
      style = "powerline";
      opts = opts // {powerline_symbol = "${ucode "E0B0"}";};
    };
  # Make a diamond segment that has the arrow (for right side)
  mkDiamondSeg = type: opts:
    mkSeg' {
      inherit type;
      style = "diamond";
      opts = opts // {leading_diamond = "${ucode "E0B2"}";};
    };
in
  outputs.lib.mkModule config "oh-my-posh" {
    programs.oh-my-posh = {
      enable = true;
      settings = {
        "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
        version = 2;
        final_space = true;
        disable_notice = true;
        var.PromptChar = "${ucode "276F"}";
        blocks = [
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              (mkPowerlineSegCorner "os" {
                foreground = "transparent";
                background = "8";
                template = " {{ if .WSL }}WSL {{ end }}{{.Icon}} ";
                properties = {
                  windows = "${ucode "E70F"}";
                };
              })
              (mkPowerlineSeg "path" {
                foreground = "transparent";
                background = "17";
                template = " {{ if eq .Path \"~\" }}${ucode "F015"}{{ else if .Writable }}${ucode "F07C"}{{ else }}${ucode "F023"}{{ end }} {{ .Path }} ";
                properties = {
                  home_icon = "~";
                  style = "agnoster_full";
                  mapped_locations = {
                    "~/Sync" = "${ucode "F0C2"}";
                  };
                };
              })
              (mkPowerlineSeg "git" {
                foreground = "transparent";
                background = "10";
                background_templates = [
                  "{{ if or (.Working.Changed) (.Staging.Changed) }}16{{ end }}"
                  "{{ if and (gt .Ahead 0) (gt .Behind 0) }}1{{ end }}"
                  "{{ if gt .Ahead 0 }}14{{ end }}"
                  "{{ if gt .Behind 0 }}1{{ end }}"
                ];
                # detached head removal stolen from https://github.com/pacifi5t/dotfiles/blob/eb0f1eedf164dccf1ff98beccf8f30d9041e6c73/common/.config/oh-my-posh/tty.json#L29
                template = " {{ .UpstreamIcon }}{{ replaceP \" ?detached (?:from|at)?\" .HEAD \"\" }}{{if or (.Working.Changed) (.Staging.Changed) }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} ${ucode "F044"}{{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} | {{ end }}{{ if .Staging.Changed }}${ucode "F046"}{{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} ${ucode "EB4B"}{{ .StashCount }}{{ end }} ";
                properties = {
                  branch_icon = "${ucode "F126"} ";
                  commit_icon = "";
                  fetch_stash_count = true;
                  fetch_status = true;
                  fetch_upstream_icon = true;
                };
              })
            ];
          }
          {
            type = "prompt";
            alignment = "right";
            overflow = "hide";
            segments = [
              (mkDiamondSeg "executionTime" {
                foreground = "transparent";
                background = "10";
                template = " {{ .FormattedMs }} ";
                properties = {threshold = 5000;};
              })
              # Stolen from https://github.com/joshua-smart/nixos/blob/1e4c70317ae862403de8171aa97747b8fba6adc2/homeManagerModules/programs/oh-my-posh.nix#L47-L51
              (mkDiamondSeg "text" {
                foreground = "3";
                background = "0";
                template = "{{ if .Env.DIRENV_ACTIVE }} ${ucode "25BC"} {{end}}";
              })
              (mkDiamondSeg "nix-shell" {
                foreground = "transparent";
                background = "15";
                template = "{{ if ne .Type \"unknown\" }} {{ .Type }} {{end}}";
              })
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              (mkSeg "text" {
                background = "transparent";
                foreground_templates = [
                  "{{if gt .Code 0}}1{{end}}"
                  "{{if eq .Code 0}}10{{end}}"
                ];
                template = "{{.Var.PromptChar}}";
              })
            ];
          }
        ];
        transient_prompt = {
          background = "transparent";
          foreground_templates = [
            "{{if gt .Code 0}}1{{end}}"
            "{{if eq .Code 0}}10{{end}}"
          ];
          template = "{{.Var.PromptChar}} ";
        };
      };
    };
  }
