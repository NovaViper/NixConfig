{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  mutt_catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "neomutt";
    rev = "f6ce83da47cc36d5639b0d54e7f5f63cdaf69f11";
    hash = "sha256-ye16nP2DL4VytDKB+JdMkBXU+Y9Z4dHmY+DsPcR2EG0=";
  };
in
{
  hm.programs.neomutt = {
    enable = true;
    unmailboxes = true;
    #changeFolderWhenSourcingAccount = true;
    sidebar = {
      enable = true;
      width = 30;
      shortPath = true;
    };
    vimKeys = true;
    sort = "reverse-threads";
    settings = {
      "mailcap_path" = "${hm-config.xdg.configHome}/neomutt/mailcap";
    };
    extraConfig = ''
      auto_view text/html
      source ${mutt_catppuccin}/neomuttrc
    '';
    binds = [
      {
        map = [
          "index"
          "pager"
        ];
        key = "\\Ck";
        action = "sidebar-prev";
      }
      {
        map = [
          "index"
          "pager"
        ];
        key = "\\Cj";
        action = "sidebar-next";
      }
      {
        map = [
          "index"
          "pager"
        ];
        key = "\\Co";
        action = "sidebar-open";
      }
      {
        key = "gg";
        action = "first-entry";
      }
      {
        key = "G";
        action = "last-entry";
      }
    ];
    macros = [
      {
        map = [
          "index"
          "pager"
        ];
        key = "<F2>";
        action = "<sync-mailbox><enter-command>source ~/.config/neomutt/personal-1<enter><change-folder>!<enter><check-stats>";
      }
      {
        map = [
          "index"
          "pager"
        ];
        key = "<F3>";
        action = "<sync-mailbox><enter-command>source ~/.config/neomutt/personal-2<enter><change-folder>!<enter><check-stats>";
      }
      {
        map = [ "index" ];
        key = "o";
        action = "<shell-escape>${lib.getExe pkgs.notmuch} new<enter>";
      }
      {
        map = [ "index" ];
        key = "\\Cn";
        action = "<vfolder-from-query>";
      }
      {
        map = [
          "index"
          "pager"
        ];
        key = "\\Cb";
        action = "<pipe-message> ${lib.getExe pkgs.urlscan}<Enter>";
      }
      {
        map = [
          "attach"
          "compose"
        ];
        key = "\\Cb";
        action = "<pipe-entry> ${lib.getExe pkgs.urlscan}<Enter>";
      }
    ];
  };

  hm.xdg.configFile."neomutt/mailcap".text = ''
    # text
    text/plain; less %s
    text/html; ${
      lib.getExe hm-config.programs.${hm-config.userVars.defaultBrowser}.package
    } --new-window %s > /dev/null 2>&1 &; nametemplate=%s.html; \
      test=test -n "$DISPLAY"; needsterminal;
    text/html; ${lib.getExe pkgs.w3m} -sixel -o auto_image=TRUE -o display_image=1 -T text/html %s; nametemplate=%s.html; needsterminal

    # image
    image/*; ${lib.getExe pkgs.feh} %s > /dev/null 2>&1 &

    # video
    video/*; ${lib.getExe pkgs.mpv} %s;

    # any application
    application/*; ${lib.getExe' pkgs.xdg-utils "xdg-open"} %s;
  '';
}
