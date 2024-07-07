{
  lib,
  stdenv,
  writeShellApplication,
  ...
}:
writeShellApplication
{
  name = "restart-plasma";

  runtimeInputs = [];

  text = ''
    # Restart script for kde
    killall .plasmashell-wr
    kstart plasmashell&
  '';
}
