{
  config,
  lib,
  options,
  pkgs,
  ...
}:
{
  # Enable Anti-virus
  services.clamav = {
    daemon = {
      enable = true;
      # Only root and explicitly authorized scanner clients can use clamd
      settings.LocalSocketMode = "660";
    };
    scanner = {
      enable = true;
      # Keep the standard scan targets and include the shared torrent downloads.
      scanDirectories = options.services.clamav.scanner.scanDirectories.default ++ [
        config.services.qbittorrent.serverConfig.BitTorrent.Session.DefaultSavePath
      ];
    };
    updater.enable = true;
    fangfrisch.enable = true;
  };

  # clamd needs to traverse directories created with the media group's permissions.
  users.users.clamav.extraGroups = [ "media" ];
  users.users.${config.services.qbittorrent.user}.extraGroups = [ "clamav" ];
  systemd.services.clamdscan.unitConfig.RequiresMountsFor = [
    config.services.qbittorrent.serverConfig.BitTorrent.Session.DefaultSavePath
  ];

  systemd.tmpfiles.rules = [
    # Both scanners can move files here. The sticky bit protects other owners'
    # entries; only root can list the directory.
    "d /var/lib/clamav-quarantine 1730 root clamav - -"
  ];
  systemd.services.clamdscan.serviceConfig.ExecStart = lib.mkForce (
    "${config.environment.etc."clamav/scan".source} scheduled "
    + lib.escapeShellArgs config.services.clamav.scanner.scanDirectories
  );

  environment.etc."clamav/scan".source = pkgs.writeScript "clamav-scan" ''
    #!${pkgs.python3}/bin/python3
    import os
    from pathlib import Path
    import subprocess
    import stat
    import sys
    import time

    source = sys.argv[1]
    if source not in ("scheduled", "torrent"):
        sys.exit("Unknown scan source")
    quarantine_root = Path("/var/lib/clamav-quarantine")
    quarantine = quarantine_root
    os.umask(0o077)
    started_at = time.time()
    started = time.monotonic()
    # Directory scans also encounter sockets, FIFOs and overlay whiteouts.
    # Pass only regular files, without following symlinks, and retain real errors.
    code = 0
    scanned = 0
    batch = []
    def scan_error(error):
        global code
        print(error, file=sys.stderr)
        code = 2
    def scan_batch():
        global code, scanned
        if not batch:
            return
        try:
            result = subprocess.run([
                "${config.services.clamav.package}/bin/clamdscan",
                "--move=" + str(quarantine),
                "--fdpass", "--multiscan", "--infected", "--no-summary", "--",
                *batch
            ], check=False)
            status = result.returncode
            code = max(code, status if status in (0, 1) else 2)
            scanned += len(batch)
        except OSError as error:
            scan_error(error)
        batch.clear()
    def add_file(path):
        try:
            if stat.S_ISREG(os.stat(path, follow_symlinks=False).st_mode):
                batch.append(path)
                if len(batch) >= 128:
                    scan_batch()
        except OSError as error:
            scan_error(error)
    if len(sys.argv) < 3:
        scan_error("No scan targets supplied")
    for target in sys.argv[2:]:
        # Quarantined files must not be scanned and moved again on later runs.
        if Path(os.path.abspath(target)).is_relative_to(quarantine_root):
            continue
        try:
            mode = os.stat(target, follow_symlinks=False).st_mode
        except OSError as error:
            scan_error(error)
            continue
        if stat.S_ISDIR(mode):
            for root, directories, files in os.walk(target, followlinks=False, onerror=scan_error):
                directories[:] = [name for name in directories
                    if Path(os.path.abspath(os.path.join(root, name))) != quarantine_root]
                for name in files:
                    add_file(os.path.join(root, name))
        else:
            add_file(target)
    scan_batch()
    duration = time.monotonic() - started
    finished_at = time.time()
    outcome = "clean" if code == 0 else "infected" if code == 1 else "error"
    print(f"Scan result: {outcome}; files submitted: {scanned}; duration: {duration:.3f}s", flush=True)
    print(f"Started: {time.strftime('%Y-%m-%d %H:%M:%S %z', time.localtime(started_at))}", flush=True)
    print(f"Finished: {time.strftime('%Y-%m-%d %H:%M:%S %z', time.localtime(finished_at))}", flush=True)
    sys.exit(code if code >= 0 else 2)
  '';
}
