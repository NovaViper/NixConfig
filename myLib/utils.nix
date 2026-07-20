{
  lib,
  username ? null,
  hostname ? null,
  ...
}:
let
  exports = {
    # List everything in a given directory (dir)
    filesInDir = dir: lib.filesystem.listFilesRecursive dir;

    # List only nix files in a given path (path), if it's a file, then we should return the file itself. Any invalid paths will be skipped
    listNixFilesForPath =
      path:
      if lib.pathIsRegularFile path then
        path
      else
        builtins.filter (path: !lib.hasPrefix "_" path && lib.hasSuffix ".nix" path) (
          exports.filesInDir path
        );

    # Import all nix files in a given list of directories and/or files (paths)
    importPaths = paths: lib.flatten (map exports.listNixFilesForPath paths);

    # Resolve a feature to either `features/foo.nix` or `features/foo/`
    resolveFeature =
      feature:
      let
        file = ../config/features + "/${feature}.nix";
        dir = ../config/features + "/${feature}";
      in
      if builtins.pathExists file then
        file
      else if builtins.pathExists dir then
        dir
      else
        throw "Feature '${feature}' does not exist.";

    # Import the given feature folders/files located in the features folder
    importFeatures =
      features:
      let
        normalizeNamespace =
          namespace: values:
          if lib.isList values then
            map (value: "${namespace}/${value}") values
          else
            [ "${namespace}/${values}" ];

        normalizeFeatures =
          if lib.isList features then
            features
          else
            lib.concatLists (lib.mapAttrsToList normalizeNamespace features);
      in
      exports.importPaths (map exports.resolveFeature normalizeFeatures);

    # Take a base path (baseDir) and a list of subfolders/subfiles (breadcrumbs) and combine them into a normalized path
    mkPath =
      baseDir: breadcrumbs:
      lib.removeSuffix "/" (
        baseDir + "/${lib.strings.concatStringsSep "/" (lib.filter (x: x != null) breadcrumbs)}"
      );

    # GPG command for checking if there is a hardware key present
    isGpgUnlocked =
      pkgs:
      "${lib.getExe' pkgs.procps "pgrep"} 'gpg-agent' &> /dev/null && ${lib.getExe' pkgs.gnupg "gpg-connect-agent"} 'scd getinfo card_list' /bye | ${lib.getExe pkgs.gnugrep} SERIALNO -q";

    useStylix = config: builtins.hasAttr "stylix" config;

    # Most of these are left null since I'm piggybacking off of the custom context function I've made
    mkMu4eContext =
      {
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
      }:
      ''
        (mu4e-quick-context
            ${
              lib.concatStringsSep "\n    " (
                lib.filter (v: v != "") [
                  '':c-name      "${contextName}"''
                  '':maildir     "${maildir}"''
                  '':mail        "${addr}"''
                  '':smtp        "${smtp}"''
                  (lib.optionalString (smtpAddr != null) '':smtp-mail   "${smtpAddr}"'')
                  (lib.optionalString (smtpPort != null) ":smtp-port   ${toString smtpPort}")
                  (lib.optionalString (smtpType != null) '':smtp-type   "${smtpType}"'')
                  (lib.optionalString (sentAction != null) '':sent-action "${sentAction}"'')
                  (lib.optionalString (fullName != null) '':name        "${fullName}"'')
                  (lib.optionalString (signature != null) '':sig         "${signature}"'')
                ]
              )
            })
      '';

    flattenPackages =
      let
        recurse =
          prefix: attrs:
          lib.foldlAttrs (
            acc: name: value:
            if lib.isDerivation value then
              acc
              // {
                "${prefix}${name}" = value;
              }
            else if lib.isAttrs value && (value.recurseForDerivations or false) then
              acc // recurse "${prefix}${name}." value
            else
              acc
          ) { } attrs;
      in
      recurse "";
  };
in
exports
