{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.mbsync.enable = true;

  hm.services.mbsync = {
    enable = true;
    frequency = "*:0/10";
    preExec = "${lib.getExe hm-config.programs.mbsync.package} -Ha";
    #postExec = "${lib.getExe config.programs.mu.package} index";
    postExec = "${lib.getExe pkgs.notmuch} new";
  };

  # Add check to ensure to only run mbsync when my hardware key(s) are inserted
  hm.systemd.user.services.mbsync.Service.ExecCondition =
    ''/bin/sh -c "${myLib.utils.isGpgUnlocked pkgs}"'';
}
