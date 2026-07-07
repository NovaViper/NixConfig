{
  config,
  lib,
  myLib,
  inputs,
  ...
}:
let

  hm-config = config.hm;
  myselfName = "novaviper";
  secrets = inputs.nix-secrets.${myselfName}.email;

  commonPatterns = [
    "INBOX"
    "Sent"
    "Drafts"
    "Junk"
    "Trash"
  ];

  mailAccounts = {
    personal-1 = {
      address = secrets.personal1.address;

      aliases = [
        "${config.vars.user.email}"
        "${secrets.personal1.work}"
        "${secrets.personal1.school}"
        "${secrets.personal1.shop}"
      ];

      extra = {
        primary = true;
        smtp.host = "smtp.mailbox.org";
        imap = {
          host = "imap.mailbox.org";
          tls.useStartTls = true;
        };

        neomutt.extraConfig =
          let
            shortCfg = hm-config.accounts.email.accounts.personal-1;

            addresses = lib.flatten [ shortCfg.address ] ++ shortCfg.aliases;
          in
          ''
            alternates "${lib.concatStringsSep "|" addresses}"
          '';

        mbsync.patterns = commonPatterns;
      };
    };

    personal-2 = {
      address = secrets.personal2;

      extra = {
        smtp.host = "smtp.gmail.com";

        # Declaring ports for Gmail breaks it!!
        imap.host = "imap.gmail.com";
        mbsync.extraConfig.channel = lib.Force null;
        mbsync.groups.personal-2 = {
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

    personal-3 =
      let
        tls = {
          enable = true;
          useStartTls = true;
          certificatesFile = "${hm-config.xdg.configHome}/protonmail/cert.pem";
        };
      in
      {
        address = secrets.personal3;
        hostTag = "protonmail/${config.networking.hostName}";
        extra = {
          smtp = {
            inherit tls;
            host = "127.0.0.1";
            port = 1025;
          };

          imap = {
            inherit tls;
            host = "127.0.0.1";
            port = 1143;
          };

          mbsync.patterns = commonPatterns;
        };
      };
  };
in
{
  _module.args = {
    inherit mailAccounts;
  };
}
