{
  config,
  lib,
  pkgs,
  ...
}: let
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
  mail-secrets = utils.esecrets.mail;
in {
  xdg.configFile = lib.mkIf (config.programs.mu.enable) {
    "doom/mu4e-accounts.el".text = ''
      ;;; mu4e-accounts.el -*- lexical-binding: t; -*-
      (setq mu4e-contexts
            `(,(dmu4e-context
                :c-name  "Google"
                :maildir "personal-2"
                :mail    "${mail-secrets.personal-2-address}"
                :smtp    "smtp.gmail.com"
                :sent-action delete)

              ,(dmu4e-context
                :c-name  "Mailbox"
                :maildir "personal-1"
                :mail    "${mail-secrets.personal-1.address}"
                :smtp    "smtp.mailbox.org")

              ,(dmu4e-context
                :c-name    "1-Mailbox-code-alias"
                :maildir   "personal-1"
                :mail      "coder.nova99@mailbox.org"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}")

              ,(dmu4e-context
                :c-name    "2-Mailbox-work-alias"
                :maildir   "personal-1"
                :mail      "${mail-secrets.personal-1.alias-work}"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}"
                :name      "${mail-secrets.personal-1.alias-name}"
                :sig       "Sincerely, ${mail-secrets.personal-1.alias-name}")

              ,(dmu4e-context
                :c-name    "3-Mailbox-school-alias"
                :maildir   "personal-1"
                :mail      "${mail-secrets.personal-1.alias-school}"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}"
                :name      "${mail-secrets.personal-1.alias-name}"
                :sig       "Sincerely, ${mail-secrets.personal-1.alias-name}")

              ,(dmu4e-context
                :c-name    "4-Mailbox-shop-alias"
                :maildir   "personal-1"
                :mail      "${mail-secrets.personal-1.alias-shop}"
                :smtp      "smtp.mailbox.org"
                :smtp-mail "${mail-secrets.personal-1.address}"))
            )
    '';
  };
}
