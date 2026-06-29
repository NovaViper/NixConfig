{
  config,
  lib,
  pkgs,
  mailAccounts,
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
  configPath = hm-config.xdg.configHome;
  neomumttConfig = "${configPath}/neomutt";
in
{
  hm.home.packages = [ pkgs.my-scripts.mutt-picker ];

  hm.programs.neomutt = {
    enable = true;
    editor =
      let
        # Get the default editor from our session variables.
        editorBase = config.home.sessionVariables.EDITOR or "$EDITOR";

        # Extra options to set for vi/vim/neovim for editing mail.
        vimOptions = "-c 'set syntax=mail ft=mail enc=utf-8 spell spelllang=en'";

        inherit (lib) hasSuffix;

        # Check if the given editor is probably vim or neovim.
        isVim = e: (hasSuffix "vi" e) || (hasSuffix "vim" e) || (hasSuffix "nvim" e);

        # Add the Vim options to the editor if it looks like (neo)vim.
        editor = if isVim editorBase then "${editorBase} ${vimOptions}" else "${editorBase}";
      in
      editor;
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
      "mailcap_path" = "${neomumttConfig}/mailcap";
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
        action = ":source mutt-picker|<enter>";
      }
      {
        map = [ "index" ];
        key = "o";
        action = "<shell-escape>${lib.getExe hm-config.programs.mbsync.package} -a";
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
    text/plain; ${config.hm.programs.neomutt.editor} %s
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
