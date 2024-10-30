{lib, ...}: let
  exports = {
    # Enable all modules in the list elems
    enable = elems:
      builtins.listToAttrs (map (name: {
          inherit name;
          value.enable = true;
        })
        elems);

    # Disable all modules in the list elems
    disable = elems:
      builtins.listToAttrs (map (name: {
          inherit name;
          value.enable = false;
        })
        elems);

    # Conditionally enable/disable all modules in the list elems
    enableIf = cond: elems:
      if cond
      then (exports.enable elems)
      else (exports.disable elems);

    # GPG command for checking if there is a hardware key present
    isGpgUnlocked = pkgs: "${pkgs.procps}/bin/pgrep 'gpg-agent' &> /dev/null && ${pkgs.gnupg}/bin/gpg-connect-agent 'scd getinfo card_list' /bye | ${pkgs.gnugrep}/bin/grep SERIALNO -q";

    # Concatinatinates all file paths in a given directory into one list.
    # It recurses through subdirectories. If it detects a default.nix, only that
    # file will be considered.
    concatImports = {
      path ? null,
      paths ? [],
      include ? [],
      exclude ? [],
      recursive ? true,
      filterDefault ? true,
    }:
      with lib;
      with fileset; let
        excludedFiles = filter pathIsRegularFile exclude;
        excludedDirs = filter pathIsDirectory exclude;
        isExcluded = path:
          if elem path excludedFiles
          then true
          else
            (filter (excludedDir: outputs.lib.path.hasPrefix excludedDir path)
              excludedDirs)
            != [];

        myFiles = unique ((filter (file:
            pathIsRegularFile file
            && hasSuffix ".nix" (builtins.toString file)
            && !isExcluded file) (concatMap (_path:
              if recursive
              then toList _path
              else
                mapAttrsToList (name: type:
                  _path
                  + (
                    if type == "directory"
                    then "/${name}/default.nix"
                    else "/${name}"
                  )) (builtins.readDir _path))
            (unique (
              if path == null
              then paths
              else [path] ++ paths
            ))))
          ++ (
            if recursive
            then concatMap toList (unique include)
            else unique include
          ));

        dirOfFile = builtins.map (file: builtins.dirOf file) myFiles;

        dirsWithDefaultNix =
          builtins.filter (dir: builtins.elem dir dirOfFile)
          (builtins.map (file: builtins.dirOf file) (builtins.filter (file:
            builtins.match "default.nix" (builtins.baseNameOf file) != null)
          myFiles));

        filteredFiles = builtins.filter (file:
          ! builtins.elem (builtins.dirOf file) dirsWithDefaultNix
          || builtins.match "default.nix" (builtins.baseNameOf file) != null)
        myFiles;
      in
        if filterDefault
        then filteredFiles
        else myFiles;
  };
in
  exports
