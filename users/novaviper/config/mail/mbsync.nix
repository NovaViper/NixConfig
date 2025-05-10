{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    frequency = "*:0/10";
    preExec = "${lib.getExe config.programs.mbsync.package} -Ha";
    #postExec = "${lib.getExe config.programs.mu.package} index";
    postExec = "${lib.getExe pkgs.notmuch} new";
  };

  # Add check to ensure to only run mbsync when my hardware key(s) are inserted
  systemd.user.services.mbsync.Service.ExecCondition =
    ''/bin/sh -c "${myLib.utils.isGpgUnlocked pkgs}"'';
}
