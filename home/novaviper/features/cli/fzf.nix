{ config, lib, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    # Alt-C command options
    changeDirWidgetOptions =
      [ "--preview '${pkgs.tree}/bin/tree -C {} | head -200'" ];
    # Ctrl-T command options
    fileWidgetOptions =
      [ "--bind 'ctrl-/:change-preview-window(down|hidden|)'" ];
    # Ctrl-R command options
    historyWidgetOptions = [ "--sort" "--exact" ];
  };
}
