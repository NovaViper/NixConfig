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
    importFeatures = baseName: dirs: exports.importPaths (builtins.map (d: ../. + "/${baseName}/${d}") dirs);

    # GPG command for checking if there is a hardware key present
    isGpgUnlocked = pkgs: "${lib.getExe' pkgs.procps "pgrep"} 'gpg-agent' &> /dev/null && ${lib.getExe' pkgs.gnupg "gpg-connect-agent"} 'scd getinfo card_list' /bye | ${lib.getExe pkgs.gnugrep} SERIALNO -q";

    # Get the value of a Home-manager.users option (Useful for NixOS-specific configs that can't directly access Home-Manager's config)
    getHMOption = opt: config: builtins.toString (lib.mapAttrsToList (user: hmConfig: lib.getAttrFromPath (lib.strings.splitString "." opt) hmConfig) config.home-manager.users);

    # Get the value of a user specific variable
    getUserVars = option: config: let
      username = myLib.utils.getHMOption "home.username" config;
    in
      config.userVars.${username}.${option};

    # Gets the name of the desktop file for a user's preferred terminal emulator application
    getTerminalDesktopFile = config: let
      terminal = myLib.utils.getUserVars "defaultTerminal" config;
    in
      if (terminal == "ghostty")
      then "com.mitchellh.ghostty"
      else if (terminal == "konsole")
      then "org.kde.konsole"
      else "${terminal}";

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
