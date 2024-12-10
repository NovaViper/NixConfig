{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
  mail-secrets = (myLib.secrets.evalSecret hm-config.home.username).mail;
  pass = "${hm-config.programs.password-store.package}/bin/pass";
in {
  hm.accounts.email = {
    maildirBasePath = "${hm-config.xdg.dataHome}/mail";
    accounts.personal-1 = let
      address = "${mail-secrets.personal-1.address}";
      smtp.host = "smtp.mailbox.org";
    in {
      primary = true;
      inherit address smtp;
      userName = address;
      realName = "Nova Leary";
      aliases = ["code.nova99@mailbox.org" "${mail-secrets.personal-1.alias-work}" "${mail-secrets.personal-1.alias-school}" "${mail-secrets.personal-1.alias-shop}"];
      mu.enable = true;
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
        extraConfig.account.TLSVersions = ["+1.3"];
        extraConfig.channel = {
          CopyArrivalDate = "yes";
          Create = "Both";
          Expunge = "Both";
          SyncState = "*";
        };
      };
    };

    accounts.personal-2 = let
      address = "${mail-secrets.personal-2-address}";
      smtp.host = "smtp.gmail.com";
    in {
      inherit address smtp;
      userName = address;
      realName = "Nova Leary";
      mu.enable = true;
      # Declaring ports for Gmail breaks it!!
      imap.host = "imap.gmail.com";
      passwordCommand = "${pass} Mail/${smtp.host}/${address}";
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        patterns = ["*" ''!"[Gmail]/All Mail"'' ''!"[Gmail]/Important"'' ''!"[Gmail]/Starred"'' ''!"[Gmail]/Bin"''];
        extraConfig.account.TLSVersions = ["+1.3"];
        extraConfig.channel = {
          CopyArrivalDate = "yes";
          Create = "Both";
          Expunge = "Both";
          SyncState = "*";
        };
      };
    };
  };

  hm.programs = {
    mu.enable = true;
    mbsync.enable = true;
  };

  hm.services.mbsync = {
    enable = true;
    frequency = "*:0/10";
    postExec = "${hm-config.programs.mu.package}/bin/mu index";
  };

  # Add check to ensure to only run mbsync when my hardware key is inserted
  hm.systemd.user.services.mbsync.Service.ExecCondition = ''/bin/sh -c "${myLib.utils.isGpgUnlocked pkgs}"'';

  #home.packages = with pkgs; [qtpass];

  create.configFile = lib.mkIf config.modules.doom-emacs.enable {
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
