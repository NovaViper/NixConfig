{
  lib,
  myLib,
  ...
}: let
  exports = {
    # List everything in a given directory (dir)
    filesInDir = dir: lib.filesystem.listFilesRecursive dir;

    # List only nix files in a given path (path), if it's a file, then we should return the file itself. Any invalid paths will be skipped
    listNixFilesForPath = path:
      if lib.pathIsRegularFile path
      then path
      else builtins.filter (lib.hasSuffix ".nix") (exports.filesInDir path);

    # Import all nix files in a given list of directories and/or files (paths)
    importPaths = paths: lib.flatten (builtins.map exports.listNixFilesForPath paths);

    # Import the given feature folders (dirs) at the given base folder name (baseName)
    importFeatures = baseName: dirs: exports.importPaths (builtins.map (d: ../features + "/${baseName}/${d}") dirs);

    # GPG command for checking if there is a hardware key present
    isGpgUnlocked = pkgs: "${lib.getExe' pkgs.procps "pgrep"} 'gpg-agent' &> /dev/null && ${lib.getExe' pkgs.gnupg "gpg-connect-agent"} 'scd getinfo card_list' /bye | ${lib.getExe pkgs.gnugrep} SERIALNO -q";

    getUserVars = option: config: builtins.toString config.userVars.${option};

    getTerminalDesktopFile = config: let
      terminal = exports.getUserVars "defaultTerminal" config;
    in
      if terminal == "ghostty"
      then "com.mitchellh.ghostty"
      else if terminal == "konsole"
      then "org.kde.konsole"
      else terminal;

    getUserHMVar' = opt: user: config: lib.getAttrFromPath (lib.strings.splitString "." opt) config.home-manager.users.${user};

    getMainUserHMVar = opt: config: exports.getUserHMVar' opt config.hostVars.primaryUser config;

    filterUsers = fn: cfg:
      lib.filter fn (
        if cfg ? home-manager
        then lib.attrValues cfg.home-manager.users
        else []
      );

    #getHMOption' = opt: config: lib.mapAttrsToList (user: hmConfig: lib.getAttrFromPath (lib.strings.splitString "." opt) hmConfig) config.home-manager.users;

    #getHMOption = opt: config: builtins.toString (exports.getHMOption' opt config);

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
  };
in
  exports
