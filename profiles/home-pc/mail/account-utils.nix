{
  config,
  lib,
  pkgs,
  mailAccounts,
  ...
}:
let
  hm-config = config.hm;
  myselfName = "novaviper";
  # passwordCmd =
  #   smtpHost: address:
  #   "gpg -q --for-your-eyes-only --no-tty -d ~/.authinfo.gpg | awk '/machine
  #   ${smtpHost} login ${address}/ {print $NF}'";
  passwordCmd =
    smtpHost: address: "${lib.getExe hm-config.programs.password-store.package} ${smtpHost}/${address}";

  mkVirtualMailboxes = accountName: [
    {
      name = "Inbox";
      query = "folder:/${accountName}/ tag:inbox";
    }
    {
      name = "Sent";
      query = "folder:/${accountName}/ tag:sent";
    }
    {
      name = "Drafts";
      query = "folder:/${accountName}/ tag:drafts";
    }
    {
      name = "Archive";
      query = "folder:/${accountName}/ tag:archive";
    }
    {
      name = "Spam";
      query = "folder:/${accountName}/ tag:spam";
    }
    {
      name = "Trash";
      query = "folder:/${accountName}/ tag:trash";
    }
  ];

  mkMailAccount =
    accountName:
    {
      address,
      hostTag ? null,
      aliases ? [ ],
      extra ? { },
    }:
    let
      cfg = lib.recursiveUpdate {
        inherit address aliases;
        userName = address;
        realName = myselfName;
        # mu.enable = true;
        # Send Email
        msmtp.enable = true;
        # Email Client
        neomutt.enable = true;
        # Index Email
        notmuch = {
          enable = true;
          neomutt = {
            enable = true;
            virtualMailboxes = mkVirtualMailboxes accountName;
          };
        };
        # Sync Email
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          extraConfig.account.TLSVersions = [ "+1.3" ];
          extraConfig.channel = {
            CopyArrivalDate = "yes";
            Create = "Both";
            Expunge = "Both";
            SyncState = "*";
          };
        };
      } extra;

      passwordKey = if hostTag != null then hostTag else cfg.smtp.host;
    in
    cfg
    // {
      passwordCommand = passwordCmd passwordKey address;
    };
in
{
  hm.accounts.email = {
    maildirBasePath = "${hm-config.xdg.dataHome}/mail";

    accounts = lib.mapAttrs (accountName: cfg: mkMailAccount accountName cfg) mailAccounts;
  };
}
