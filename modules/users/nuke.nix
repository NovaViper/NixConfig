{
  outputs,
  config,
  name,
  pkgs,
  ...
}: {
  options = {
    nukeFiles = outputs.lib.mkOption {
      default = [];
      type = outputs.lib.types.listOf outputs.lib.types.str;
      description = "Files to nuke to pave the way for Home Manager";
    };
  };

  config = outputs.lib.mkIf (config.nukeFiles != []) {
    systemd.user.services.home-nuker = {
      Unit = {
        Description = "Remove files Home Manager has beef with";
        # PartOf = [ "home-manager-${name}.target" ];
        Before = ["home-manager-${name}.service"];
        Wants = ["home-manager-${name}.service"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = let
          commands =
            builtins.concatStringsSep "\n"
            (map (file: ''rm -f "${file}"'') config.nukeFiles);
        in
          builtins.toString (pkgs.writeShellScript "home-nuker" ''
            #!/run/current-system/sw/bin/bash
            set -o errexit
            set -o nounset

            printf 'Nuking files so Home Manager can get its will\n'

            ${commands}
          '');
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
