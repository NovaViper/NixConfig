{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [appimage-run];

  # Register AppImage files as a binary type to binfmt_misc, allowing them to be invoked directly
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
    magicOrExtension = "\\x7fELF....AI\\x02";
  };
}
