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
    settings.maildir.synchronize_flags = true;
    hooks = {
      preNew = "${lib.getExe hm-config.programs.mbsync.package} -a";
    };
  };
}
