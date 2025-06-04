{ writeShellApplication, tmux, ... }:
writeShellApplication {
  name = "tmux-popup";

  runtimeInputs = [ tmux ];

  # Got this from
  # https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/
  # and updated version from linked dotfiles
  # https://codeberg.org/willhbr/dotfiles/src/commit/dc50284d2aff7125069db8e5e4d1fcb0b301aea1/bin/show-tmux-popup.sh
  text = ''
    #!/bin/bash
    session="$(tmux display -p '_popup_#S')"

    if ! tmux has -t "$session" 2> /dev/null; then
      parent_session="$(tmux display -p '#{session_id}')"
      session_id="$(tmux new-session -c '#{pane_current_path}' -dP -s "$session" -F '#{session_id}' -e TMUX_PARENT_SESSION="$parent_session")"
      exec tmux set-option -t "$session_id" key-table popup \; \
        set-option -t "$session_id" status off \; \
        set-option -t "$session_id" prefix None \; \
        attach -t "$session"
    fi

    exec tmux attach -t "$session" > /dev/null
  '';
}
