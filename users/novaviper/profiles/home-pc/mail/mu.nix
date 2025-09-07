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
  userVars = opt: myLib.utils.getUserVars opt hm-config;
in
{
  #hm.programs.mu.enable = true;

  hm.xdg.configFile =
    let
      acct = hm-config.accounts.email.accounts;
      aliasElem = a: i: builtins.elemAt a.aliases i;
      primaryTemplate = {
        account = acct.personal-1;
        fullName = secrets.personal1.fullName;
        smtpAddr = acct.personal-1.address;
        signature = "Sincerely, ${primaryTemplate.fullName}";
      };
    in
    lib.mkIf (userVars "defaultEditor" == "doom-emacs") {
      "doom/mu4e-accounts.el".text = ''
        ;;; mu4e-accounts.el -*- lexical-binding: t; -*-
        (after! mu4e
          :config
          (setq mu4e-contexts
          (list ${
            lib.concatStringsSep "\n    " (
              lib.filter (v: v != "") [
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
                  inherit (primaryTemplate) account smtpAddr;
                  contextName = "1-Mailbox-code-alias";
                  addr = aliasElem acct.personal-1 0;
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate)
                    account
                    smtpAddr
                    fullName
                    signature
                    ;
                  contextName = "2-Mailbox-work-alias";
                  addr = aliasElem acct.personal-1 1;
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate)
                    account
                    smtpAddr
                    fullName
                    signature
                    ;
                  contextName = "3-Mailbox-school-alias";
                  addr = aliasElem acct.personal-1 2;
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate) account smtpAddr;
                  contextName = "4-Mailbox-shop-alias";
                  addr = aliasElem acct.personal-1 3;
                })
              ]
            )
          })))
        ;;; mu4e-accounts.el ends here
      '';
    };

}
