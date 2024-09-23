{
  outputs,
  config,
  name,
  pkgs,
  ...
}: let
  activationScript = let
    commands =
      builtins.concatStringsSep "\n"
      (map (file: ''rm -fv "${file}"'') config.nukeFiles);
  in ''
    printf 'Nuking files so Home Manager can get its will\n'

    ${commands}
    printf 'Nuking done!'
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
    nixos.system.userActivationScripts.home-conflict-file-nuker.text = activationScript;
  };
}
