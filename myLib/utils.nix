{
  lib,
  myLib,
  ...
}: let
  exports = {
    importFromPath = {
      path,
      dirs ? [],
      files,
    }: let
      filesToImport = builtins.map (f: path + "/${f}.nix") files;
      dirsToImport = builtins.map (d: path + "/${d}") dirs;
    in
      filesToImport ++ dirsToImport;

    # GPG command for checking if there is a hardware key present
    isGpgUnlocked = pkgs: "${lib.getExe' pkgs.procps "pgrep"} 'gpg-agent' &> /dev/null && ${lib.getExe' pkgs.gnupg "gpg-connect-agent"} 'scd getinfo card_list' /bye | ${lib.getExe pkgs.gnugrep} SERIALNO -q";

    getTerminalDesktopFile = config:
      if (config.userVars.defaultTerminal == "ghostty")
      then "com.mitchellh.ghostty"
      else if (config.userVars.defaultTerminal == "konsole")
      then "org.kde.konsole"
      else "${config.userVars.defaultTerminal}";

    # Most of these are left null since I'm piggybacking off of the custom context function I've made
    mkMu4eContext = {
      account,
      addr ? "${account.address}",
      contextName,
      fullName ? null,
      maildir ? "${account.name}",
      sentAction ? null,
      signature ? null,
      smtp ? "${account.smtp.host}",
      smtpAddr ? null,
      smtpPort ? null,
      smtpType ? null,
    }: ''
      (mu4e-quick-context
          ${lib.concatStringsSep "\n    " (lib.filter (v: v != "") [
        '':c-name      "${contextName}"''
        '':maildir     "${maildir}"''
        '':mail        "${addr}"''
        '':smtp        "${smtp}"''
        (lib.optionalString (smtpAddr != null) '':smtp-mail   "${smtpAddr}"'')
        (lib.optionalString (smtpPort != null) '':smtp-port   ${toString smtpPort}'')
        (lib.optionalString (smtpType != null) '':smtp-type   "${smtpType}"'')
        (lib.optionalString (sentAction != null) '':sent-action "${sentAction}"'')
        (lib.optionalString (fullName != null) '':name        "${fullName}"'')
        (lib.optionalString (signature != null) '':sig         "${signature}"'')
      ])})
    '';

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
        excludedFiles = filter (path: pathIsRegularFile path) exclude;
        excludedDirs = filter (path: pathIsDirectory path) exclude;
        isExcluded = path:
          if elem path excludedFiles
          then true
          else
            (filter (excludedDir: lib.path.hasPrefix excludedDir path)
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
            then concatMap (path: toList path) (unique include)
            else unique include
          ));

        dirOfFile = builtins.map (file: builtins.dirOf file) myFiles;

        dirsWithDefaultNix =
          builtins.filter (dir: builtins.elem dir dirOfFile)
          (builtins.map (file: builtins.dirOf file) (builtins.filter (file:
            builtins.match "default.nix" (builtins.baseNameOf file) != null)
          myFiles));

        filteredFiles = builtins.filter (file:
          builtins.elem (builtins.dirOf file) dirsWithDefaultNix
          == false
          || builtins.match "default.nix" (builtins.baseNameOf file) != null)
        myFiles;
      in
        if filterDefault
        then filteredFiles
        else myFiles;
  };
in
  exports
