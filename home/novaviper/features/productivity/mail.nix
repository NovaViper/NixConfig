{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
  mail-secrets = utils.esecrets.mail;
  pass = "${config.programs.password-store.package}/bin/pass";
in {
  accounts.email = {
    maildirBasePath = "${config.xdg.cacheHome}/mail";
    accounts = {
      personal-1 = rec {
        primary = true;
        address = "${mail-secrets.personal-1.address}";
        userName = address;
        realName = "Nova Leary";
        aliases = ["code.nova99@mailbox.org" "${mail-secrets.personal-1.alias-work}" "${mail-secrets.personal-1.alias-school}" "${mail-secrets.personal-1.alias-shop}"];
        mu.enable = true;
        smtp.host = "smtp.mailbox.org";
        imap = {
          host = "imap.mailbox.org";
          tls.useStartTls = true;
        };
        passwordCommand = "${pass} Mail/${smtp.host}/${address}";
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
        address = "${mail-secrets.personal-2-address}";
        userName = address;
        realName = "Nova Leary";
        mu.enable = true;
        # Declaring ports for Gmail breaks it!!
        smtp.host = "smtp.gmail.com";
        imap.host = "imap.gmail.com";
        passwordCommand = "${pass} Mail/${smtp.host}/${address}";
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

  services.mbsync = {
    enable = true;
    frequency = "*:0/10";
    postExec = "${config.programs.mu.package}/bin/mu index";
  };

  # Add check to ensure to only run mbsync when my hardware key is inserted
  systemd.user.services.mbsync.Service.ExecCondition = let
    gpgCmds = import ../cli/gpg-commands.nix {inherit pkgs;};
  in ''/bin/sh -c "${gpgCmds.isUnlocked}"'';

  home.packages = with pkgs; [qtpass];
}
