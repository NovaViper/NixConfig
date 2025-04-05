{
  config,
  lib,
  myLib,
  ...
}: let
  hm-config = config.hm;
in {
  hm.programs.topgrade.enable = true;
  hm.programs.topgrade.settings = {
    misc = {
      pre_sudo = true;
      cleanup = true;
      skip_notify = false;
      display_time = true;
      set_title = true;
    };
    linux = {
      nix_arguments = "--flake ${myLib.flakePath hm-config}";
      home_manager_arguments = ["--flake" "${myLib.flakePath hm-config}"];
    };
  };
}
