{
  config,
  lib,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.notmuch = {
    enable = true;
    maildir.synchronizeFlags = true;
    hooks = {
      preNew = "${lib.getExe hm-config.programs.mbsync.package} -a";
    };
  };
}
