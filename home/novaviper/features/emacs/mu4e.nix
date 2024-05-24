{
  config,
  lib,
  pkgs,
  ...
}: let
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
in {
  xdg.configFile = lib.mkIf (config.programs.mu.enable) {
    "doom/mu4e-contrib.el".source =
      fetchGit {
        url = "https://github.com/djcb/mu";
        rev = "a9495f7be55621cfbc9b646564717cead77055a3";
      }
      + "/mu4e/mu4e-contrib.el";

    "doom/mu4e-accounts.el".text = ''
      (use-package! mu4easy
        :custom
        (setq mu4easy-contexts
              '((mu4easy-context
                 :c-name  "Google"
                 :maildir "personal-2"
                 :mail    "${utils.esecrets.mail.personal-2-address}"
                 :smtp    "smtp.gmail.com"
                 :sent-action delete)

                (mu4easy-context
                 :c-name  "Mailbox"
                 :maildir "personal-1"
                 :mail    "${utils.esecrets.mail.personal-1-address}"
                 :smtp    "smtp.mailbox.org")

                (mu4easy-context
                 :c-name    "1-Mailbox-code-alias"
                 :maildir   "personal-1"
                 :mail      "${utils.esecrets.mail.personal-1-code-alias}"
                 :smtp      "smtp.mailbox.org"
                 :smtp-mail "${utils.esecrets.mail.personal-1-address}")

                (mu4easy-context
                  :c-name    "2-Mailbox-work-alias"
                  :maildir   "personal-1"
                  :mail      "${utils.esecrets.mail.personal-1-work-alias}"
                  :smtp      "smtp.mailbox.org"
                  :smtp-mail "${utils.esecrets.mail.personal-1-address}"
                  :name      "${utils.esecrets.mail.personal-1-name}"
                  :sig       "Sincerely, ${utils.esecrets.mail.personal-1-name}")

                (mu4easy-context
                  :c-name    "3-Mailbox-school-alias"
                  :maildir   "personal-1"
                  :mail      "${utils.esecrets.mail.personal-1-school-alias}"
                  :smtp      "smtp.mailbox.org"
                  :smtp-mail "${utils.esecrets.mail.personal-1-address}"
                  :name      "${utils.esecrets.mail.personal-1-name}"
                  :sig       "Sincerely, ${utils.esecrets.mail.personal-1-name}")

                (mu4easy-context
                  :c-name    "4-Mailbox-shop-alias"
                  :maildir   "personal-1"
                  :mail      "${utils.esecrets.mail.personal-1-shop-alias}"
                  :smtp      "smtp.mailbox.org"
                  :smtp-mail "${utils.esecrets.mail.personal-1-address}"))
      ))
    '';
  };
}
