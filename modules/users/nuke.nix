{
  outputs,
  config,
  ...
}: let
  activationScript = let
    commands =
      builtins.concatStringsSep "\n"
      (map (file: ''rm -fv "${file}" && echo Deleted "${file}"'') config.nukeFiles);
  in ''
    #!/run/current-system/sw/bin/bash
    set -o errexit
    set -o nounset

    echo "[home-nuker] Nuking files so Home Manager can get its will"

    ${commands}
  '';
in {
  options = {
    nukeFiles = outputs.lib.mkOption {
      default = [];
      type = outputs.lib.types.listOf outputs.lib.types.str;
      description = "Files to nuke to pave the way for Home Manager. Requires full path to file or ~/ path";
    };
  };

  config = outputs.lib.mkIf (config.nukeFiles != []) {
    nixos.system.userActivationScripts.home-conflict-file-nuker = activationScript;
  };
}
