{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = true;
      sync_frequency = "10m";
      search_mode = "fuzzy";
      inline_height = 16;
      keymap_mode = "vim-insert";
      keymap_cursor = {
        emacs = "blink-block";
        vim_insert = "blink-bar";
        vim_normal = "steady-block";
      };
      show_preview = true;
      enter_accept = true;
      history_filter = [
        "^gpg --key-edit"
        "^gpg --list-secret-keys"
        "^gpg --recipient"
        "^gpg --card-edit"
        "^echo"
        "-----BEGIN PGP PRIVATE KEY BLOCK-----"
        "^rm -rf"
        "^pass"
      ];
      sync.records = true;
    };
  };
}
