{
  pkgs,
  ...
}:
{
  # The much better shell history database
  hm.programs.atuin.enable = true;

  hm.home.packages = with pkgs; [ atuin-export-fish-history ];

  hm.programs.atuin.settings = {
    auto_sync = true;
    sync_frequency = "10m";
    search_mode = "fuzzy";
    inline_height = 16;
    keymap_mode = "auto";
    filter_mode_shell_up_key_binding = "host";
    show_preview = true;
    enter_accept = true;
    workspaces = true;
    history_filter = [
      "^gpg --key-edit"
      "^gpg --list-secret-keys"
      "^gpg --list-keys"
      "^gpg --recipient"
      "^gpg --card-edit"
      "^git-crypt add-gpg-user"
      "^echo"
      "-----BEGIN PGP PRIVATE KEY BLOCK-----"
      "^rm -rf"
      "^pass"
      # Taken from https://github.com/Alrefai/dotfiles/blob/bb93ea2af62207aa57671e37146d4a1e2439f1ad/home.nix#L237
      "^l(a|l|la|s|t)?( +|$)"
      "^cd( +|$)"
      "^(c|b)at( +|$)"
      "^vim?( +|$)"
      "^nvim( +|$)"
      "^env( +|$)"
      "^type( +|$)"
      "^which( +|$)"
      "^exit( +|$)"
      "^builtin( +|$)"
    ];
    cwd_filter = [
      "^/keepass"
      "^/Sync/keepass"
      "^/.password-store"
    ];
    sync.records = true;
  };
}
