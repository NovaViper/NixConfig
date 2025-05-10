{
  config,
  lib,
  ...
}:
{
  programs.notmuch = {
    enable = true;
    maildir.synchronizeFlags = true;
    hooks = {
      preNew = "${lib.getExe config.programs.mbsync.package} -a";
    };
  };
}
