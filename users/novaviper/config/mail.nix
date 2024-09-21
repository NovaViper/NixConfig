{
  config,
  outputs,
  pkgs,
  ...
}: let
  mail-secrets = (outputs.lib.evalSecret config.home.username).mail;
  pass = "${config.programs.password-store.package}/bin/pass";
in {
  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/mail";
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
    gpgCmds = import ../../../modules/users/gpg/gpg-commands.nix {inherit pkgs;};
  in ''/bin/sh -c "${gpgCmds.isUnlocked}"'';

  #home.packages = with pkgs; [qtpass];

  xdg.configFile = outputs.lib.mkIf (config.programs.emacs.enable) {
    "doom/mu4e-accounts.el".text = ''
      ;;; mu4e-accounts.el -*- lexical-binding: t; -*-
      (use-package! mu4easy
        :demand
        :config
        (mu4easy-mode)
        (setq mu4easy-contexts
              '((mu4easy-context
                :c-name  "Google"
                :maildir "personal-2"
                :mail    "${mail-secrets.personal-2-address}"
                :smtp    "smtp.gmail.com"
                :sent-action delete)

                (mu4easy-context
                :c-name  "Mailbox"
                :maildir "personal-1"
                :mail    "${mail-secrets.personal-1.address}"
                :smtp    "smtp.mailbox.org")

                (mu4easy-context
                :c-name    "1-Mailbox-code-alias"
                :maildir   "personal-1"
                :mail      "coder.nova99@mailbox.org"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}")

                (mu4easy-context
                :c-name    "2-Mailbox-work-alias"
                :maildir   "personal-1"
                :mail      "${mail-secrets.personal-1.alias-work}"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}"
                :name      "${mail-secrets.personal-1.alias-name}"
                :sig       "Sincerely, ${mail-secrets.personal-1.alias-name}")

                (mu4easy-context
                :c-name    "3-Mailbox-school-alias"
                :maildir   "personal-1"
                :mail      "${mail-secrets.personal-1.alias-school}"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}"
                :name      "${mail-secrets.personal-1.alias-name}"
                :sig       "Sincerely, ${mail-secrets.personal-1.alias-name}")

                (mu4easy-context
                :c-name    "4-Mailbox-shop-alias"
                :maildir   "personal-1"
                :mail      "${mail-secrets.personal-1.alias-shop}"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}"))
              ))
      ;;; mu4e-accounts.el ends here
    '';
  };
}
