{
  config,
  lib,
  ...
}:
let
  hm-config = config.hm;
in
{
  # Fuzzy finder
  hm.programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 40%"
      "--exact"
      "--multi"
    ]
    ++ lib.optionals hm-config.programs.tmux.enable [ "--tmux 75%,50%" ];
    # Alt-C command options
    changeDirWidget.options = [ "--preview 'eza --tree --color=always {} | head -200'" ];
    # Ctrl-T command options
    fileWidget.options = [ "--bind 'ctrl-/:change-preview-window(down|hidden|)'" ];
  };
}
