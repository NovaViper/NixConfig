{
  config,
  lib,
  inputs,
  ...
}:
let
  myselfName = "novaviper";
  secrets = inputs.nix-secrets.${myselfName}.email;
  passwordCmd =
    smtpHost: email:
    "gpg -q --for-your-eyes-only --no-tty -d ~/.authinfo.gpg | awk '/machine ${smtpHost} login ${email}/ {print $NF}'";
in
{
  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/mail";
    accounts.personal-1 =
      let
        address = "${secrets.personal1.address}";
        smtp.host = "smtp.mailbox.org";
      in
      {
        primary = true;
        inherit address smtp;
        userName = address;
        realName = "${myselfName}";
        aliases = [
          "code.nova99@mailbox.org"
          "${secrets.personal1.work}"
          "${secrets.personal1.school}"
          "${secrets.personal1.shop}"
        ];
        imap = {
          host = "imap.mailbox.org";
          tls.useStartTls = true;
        };
        #passwordCommand = "${pass} Mail/${smtp.host}/${address}";
        passwordCommand = passwordCmd smtp.host address;
        #mu.enable = true;
        msmtp.enable = true; # Send Email
        neomutt = {
          # Email Client
          enable = true;
          extraConfig =
            let
              shortCfg = config.accounts.email.accounts.personal-1;
              addresses = lib.flatten [ shortCfg.address ] ++ shortCfg.aliases;
            in
            ''
              alternates "${lib.concatStringsSep "|" addresses}"
            '';
        };
        notmuch = {
          # Index Email
          enable = true;
          neomutt.enable = true;
          neomutt.virtualMailboxes = [
            {
              name = "Inbox";
              query = "folder:/personal-1/ tag:inbox";
            }
            {
              name = "Sent";
              query = "folder:/personal-1/ tag:sent";
            }
            {
              name = "Drafts";
              query = "folder:/personal-1/ tag:drafts";
            }
            {
              name = "Archive";
              query = "folder:/personal-1/ tag:archive";
            }
            {
              name = "Spam";
              query = "folder:/personal-1/ tag:spam";
            }
            {
              name = "Trash";
              query = "folder:/personal-1/ tag:trash";
            }
          ];
        };
        mbsync = {
          # Fetch/Index Email
          enable = true;
          create = "both";
          expunge = "both";
          patterns = [
            "Inbox"
            "Sent"
            "Drafts"
            "Spam"
            "Trash"
          ];
          extraConfig.account.TLSVersions = [ "+1.3" ];
          extraConfig.channel = {
            CopyArrivalDate = "yes";
            Create = "Both";
            Expunge = "Both";
            SyncState = "*";
          };
        };
      };

    accounts.personal-2 =
      let
        address = "${secrets.personal2}";
        smtp.host = "smtp.gmail.com";
      in
      {
        inherit address smtp;
        userName = address;
        realName = "${myselfName}";
        # Declaring ports for Gmail breaks it!!
        imap.host = "imap.gmail.com";
        #passwordCommand = "${pass} Mail/${smtp.host}/${address}";
        passwordCommand = passwordCmd smtp.host address;
        #mu.enable = true;
        msmtp.enable = true; # Send Email
        # Email Client
        neomutt.enable = true;
        notmuch = {
          # Index Email
          enable = true;
          neomutt.enable = true;
          neomutt.virtualMailboxes = [
            {
              name = "Inbox";
              query = "folder:/personal-1/ tag:inbox";
            }
            {
              name = "Sent";
              query = "folder:/personal-1/ tag:sent";
            }
            {
              name = "Drafts";
              query = "folder:/personal-1/ tag:drafts";
            }
            {
              name = "Archive";
              query = "folder:/personal-1/ tag:archive";
            }
            {
              name = "Spam";
              query = "folder:/personal-1/ tag:spam";
            }
            {
              name = "Trash";
              query = "folder:/personal-1/ tag:trash";
            }
          ];
        };
        mbsync = {
          # Fetch/Index Email
          enable = true;
          create = "both";
          expunge = "both";
          extraConfig.account.TLSVersions = [ "+1.3" ];
          groups = {
            personal-2 = {
              channels = {
                Inbox = {
                  farPattern = "INBOX";
                  nearPattern = "INBOX";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
                Archive = {
                  farPattern = "[Gmail]/All Mail";
                  nearPattern = "Archive";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
                Spam = {
                  farPattern = "[Gmail]/Spam";
                  nearPattern = "Spam";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
                Trash = {
                  farPattern = "[Gmail]/Trash";
                  nearPattern = "Trash";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
                Important = {
                  farPattern = "[Gmail]/Important";
                  nearPattern = "Important";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
                Sent = {
                  farPattern = "[Gmail]/Sent Mail";
                  nearPattern = "Sent";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
                FarDrafts = {
                  farPattern = "[Gmail]/Drafts";
                  nearPattern = "FarDrafts";
                  extraConfig = {
                    Create = "Near";
                    Expunge = "Both";
                  };
                };
              };
            };
          };
        };
      };
  };
}
