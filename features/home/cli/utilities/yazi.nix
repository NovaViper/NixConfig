{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        sort_dir_first = true;
        show_hidden = true;
        show_symlink = true;
        mouse_events = [
          "click"
          "scroll"
        ];
      };
      input = {
        cursor_blink = true;
      };
    };
  };
}
