{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
  hm.programs.fish = {
    shellInit = lib.mkAfter (lib.concatStringsSep "\n" [
      (lib.optionalString hm-config.programs.tmux.enable
        ''
          # Run Tmux on startup
          if test -z $TMUX;
            ${lib.getExe pkgs.tmux} attach >/dev/null 2>&1 || ${lib.getExe pkgs.tmuxp} load ${hm-config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
            exit
          end
        '')
    ]);

    functions = {
      fish_greeting = ''
        if test $(tput cols) -ge 75 || test $(tput cols) -ge 100;
          ${lib.getExe pkgs.toilet} -f pagga "FOSS AND BEAUTIFUL" --metal
          ${lib.getExe pkgs.fastfetch}
        end
      '';
      reload = {
        description = "Reload the shell";
        body = ''
          clear
          exec fish
        '';
      };
      list-keys = {
        argumentNames = ["prog"];
        description = "List the keybindings for various programs Supported: wezterm, alacritty, tmux";
        body = ''
          if not test -n $prog;
              echo "Cannot be blank! Parameters must be wezterm,alacritty,tmux"
          else if test $prog = "wezterm";
              xdg-open "https://wezfurlong.org/wezterm/config/default-keys.html" &>/dev/null
          else if test $prog = "alacritty";
              xdg-open "https://github.com/alacritty/alacritty/blob/master/alacritty.yml" &>/dev/null
          else if test $prog = "tmux";
              xdg-open "https://gist.github.com/mzmonsour/8791835#file-tmux-default-bindings-txt" &>/dev/null
          else
              echo "Cannot be blank! Parameters must be wezterm,alacritty,tmux"
          end
        '';
      };
    };
  };
}
