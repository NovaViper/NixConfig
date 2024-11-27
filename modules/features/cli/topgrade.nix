{
  config,
  lib,
  ...
}: let
  hm-config = config.hm;
in
  lib.utilMods.mkModule config "topgrade" {
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
        nix_arguments = "--flake ${lib.flakePath hm-config}";
        home_manager_arguments = ["--flake" "${lib.flakePath hm-config}"];
      };
    };
  }
