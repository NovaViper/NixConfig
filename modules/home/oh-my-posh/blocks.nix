{
  lib,
  internals,
}: [
  {
    type = "prompt";
    alignment = "left";
    newline = true;
    segments = [
      (internals.mkPowerlineSegCorner "os" {
        foreground = "transparent";
        background = "8";
        template = " {{ if .WSL }}WSL {{ end }}{{.Icon}} ";
        properties.windows = "${internals.ucode "E70F"}";
      })
      (internals.mkPowerlineSeg "path" {
        foreground = "transparent";
        background = "17";
        template = " {{ if eq .Path \"~\" }}${internals.ucode "F015"}{{ else if .Writable }}${internals.ucode "F07C"}{{ else }}${internals.ucode "F023"}{{ end }} {{ .Path }} ";
        properties = {
          home_icon = "~";
          style = "agnoster_full";
          mapped_locations."~/Sync" = "${internals.ucode "F0C2"}";
        };
      })
      (internals.mkPowerlineSeg "git" {
        foreground = "transparent";
        background = "10";
        background_templates = [
          "{{ if or (.Working.Changed) (.Staging.Changed) }}16{{ end }}"
          "{{ if and (gt .Ahead 0) (gt .Behind 0) }}1{{ end }}"
          "{{ if gt .Ahead 0 }}14{{ end }}"
          "{{ if gt .Behind 0 }}1{{ end }}"
        ];
        # detached head removal stolen from https://github.com/pacifi5t/dotfiles/blob/eb0f1eedf164dccf1ff98beccf8f30d9041e6c73/common/.config/oh-my-posh/tty.json#L29
        template = " {{ .UpstreamIcon }}{{ replaceP \" ?detached (?:from|at)?\" .HEAD \"\" }}{{if or (.Working.Changed) (.Staging.Changed) }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} ${internals.ucode "F044"}{{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} | {{ end }}{{ if .Staging.Changed }}${internals.ucode "F046"}{{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} ${internals.ucode "EB4B"}{{ .StashCount }}{{ end }} ";
        properties = {
          branch_icon = "${internals.ucode "F126"} ";
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
      (internals.mkDiamondSeg "executionTime" {
        foreground = "transparent";
        background = "10";
        template = " {{ .FormattedMs }} ";
        properties.threshold = 5000;
      })
      # Stolen from https://github.com/joshua-smart/nixos/blob/1e4c70317ae862403de8171aa97747b8fba6adc2/homeManagerModules/programs/oh-my-posh.nix#L47-L51
      (internals.mkDiamondSeg "text" {
        foreground = "3";
        background = "0";
        template = "{{ if .Env.DIRENV_ACTIVE }} ${internals.ucode "25BC"} {{end}}";
      })
      (internals.mkDiamondSeg "nix-shell" {
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
      (internals.mkSeg "text" {
        background = "transparent";
        foreground_templates = [
          "{{if gt .Code 0}}1{{end}}"
          "{{if eq .Code 0}}10{{end}}"
        ];
        template = "{{.Var.PromptChar}}";
      })
    ];
  }
]