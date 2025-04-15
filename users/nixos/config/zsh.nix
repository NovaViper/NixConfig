{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh.initExtra = lib.mkAfter (lib.concatStringsSep "\n" [
    ''
      # Create shell prompt
      if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
        ${lib.getExe pkgs.toilet} -f pagga "ISO MAGE" --metal
        ${lib.getExe pkgs.fastfetch}
      fi
    ''
  ]);
}
