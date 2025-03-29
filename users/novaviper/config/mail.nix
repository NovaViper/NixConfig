{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
  mail-secrets = (myLib.secrets.evalSecret hm-config.home.username).mail;
  pass = "${lib.getExe hm-config.programs.password-store.package}";
  userVars = config.userVars;
  myselfName = userVars.username;
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
      realName = "${myselfName}";
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
      realName = "${myselfName}";
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
    preExec = "${lib.getExe hm-config.programs.mbsync.package} -Ha";
    postExec = "${lib.getExe hm-config.programs.mu.package} index";
  };

  # Add check to ensure to only run mbsync when my hardware key is inserted
  hm.systemd.user.services.mbsync.Service.ExecCondition = ''/bin/sh -c "${myLib.utils.isGpgUnlocked pkgs}"'';

  hm.xdg.configFile = let
    acct = hm-config.accounts.email.accounts;
    aliasElem = a: i: builtins.elemAt a.aliases i;
  in
    lib.mkIf (userVars.defaultEditor == "doom-emacs") {
      "doom/mu4e-accounts.el".text = ''
        ;;; mu4e-accounts.el -*- lexical-binding: t; -*-
        (after! mu4e
          :config
          (setq mu4e-contexts
          (list ${lib.concatStringsSep "\n    " (lib.filter (v: v != "") [
          (myLib.utils.mkMu4eContext {
            account = acct.personal-2;
            contextName = "Google";
            sentAction = "delete";
          })
          (myLib.utils.mkMu4eContext {
            account = acct.personal-1;
            contextName = "Mailbox";
          })
          (myLib.utils.mkMu4eContext {
            account = acct.personal-1;
            contextName = "1-Mailbox-code-alias";
            addr = aliasElem acct.personal-1 0;
            smtpAddr = acct.personal-1.address;
          })
          (myLib.utils.mkMu4eContext {
            account = acct.personal-1;
            contextName = "2-Mailbox-work-alias";
            fullName = mail-secrets.personal-1.alias-name;
            addr = aliasElem acct.personal-1 1;
            smtpAddr = acct.personal-1.address;
            signature = "Sincerely, ${mail-secrets.personal-1.alias-name}";
          })
          (myLib.utils.mkMu4eContext {
            account = acct.personal-1;
            contextName = "3-Mailbox-school-alias";
            fullName = mail-secrets.personal-1.alias-name;
            addr = aliasElem acct.personal-1 2;
            smtpAddr = acct.personal-1.address;
            signature = "Sincerely, ${mail-secrets.personal-1.alias-name}";
          })
          (myLib.utils.mkMu4eContext {
            account = acct.personal-1;
            contextName = "4-Mailbox-shop-alias";
            addr = aliasElem acct.personal-1 3;
            smtpAddr = acct.personal-1.address;
          })
        ])})))
        ;;; mu4e-accounts.el ends here
      '';
    };
}
