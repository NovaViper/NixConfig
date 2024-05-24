{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
in {
  accounts.email = {
    maildirBasePath = "${config.xdg.cacheHome}/mail";
    accounts = {
      personal-1 = rec {
        primary = true;
        address = "${utils.esecrets.mail.personal-1-address}";
        userName = address;
        realName = "Nova Leary";
        mu.enable = true;
        smtp.host = "smtp.mailbox.org";
        imap = {
          host = "imap.mailbox.org";
          tls.useStartTls = true;
        };
        # Use gpg authinfo file
        passwordCommand = "gpg -q --for-your-eyes-only --no-tty -d ~/.authinfo.gpg | awk '/machine ${smtp.host} login ${address}/ {print $NF}'";
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = ["INBOX" "AllMail" "Trash" "Spam" "Drafts" "Sent"];
          extraConfig.channel = {
            CopyArrivalDate = "yes";
            Create = "Both";
            Expunge = "Both";
            SyncState = "*";
          };
        };
      };

      personal-2 = rec {
        address = "${utils.esecrets.mail.personal-2-address}";
        userName = address;
        realName = "Nova Leary";
        mu.enable = true;
        # Declaring ports for Gmail breaks it!!
        smtp.host = "smtp.gmail.com";
        imap.host = "imap.gmail.com";
        passwordCommand = "gpg -q --for-your-eyes-only --no-tty -d ~/.authinfo.gpg | awk '/machine ${smtp.host} login ${address}/ {print $NF}'";
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = ["*" ''!"[Gmail]/All Mail"'' ''!"[Gmail]/Important"'' ''!"[Gmail]/Starred"'' ''!"[Gmail]/Bin"''];
          extraConfig.channel = {
            CopyArrivalDate = "yes";
            Create = "Both";
            Expunge = "Both";
            SyncState = "*";
          };
        };
      };
    };
  };

  programs = {
    mu.enable = true;
    mbsync.enable = true;
  };

  services.mbsync.enable = true;

  home.file.".authinfo.gpg".source = utils.refDots "secrets/.authinfo.gpg";
}
