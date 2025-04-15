{
  lib,
  config,
  options,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types mkMerge;
  activationScript = let
    commands = builtins.concatStringsSep "\n" (
      map (file: ''rm -fv "${file}" && echo Deleted "${file}"'') config.nukeFiles
    );
  in ''
    #!/run/current-system/sw/bin/bash
    set -o errexit
    set -o nounset

    echo "[home-nuker] Nuking files so Home Manager can get its will"

    ${commands}
  '';
in {
  options.nukeFiles = mkOption {
    type = types.listOf types.str;
    description = "Files to nuke to pave the way for Home Manager. Requires full path to file or ~/ path";
    default = null;
  };

  config = mkIf (config.nukeFiles != null) {
    # Home file nuking script that deletes stuff just before we run home-manager's activation scripts
    home.activation.home-conflict-file-nuker = lib.hm.dag.entryAfter ["checkLinkTargets"] activationScript;
  };
}
