{writeShellApplication, ...}:
writeShellApplication
{
  name = "restart-plasma";

  runtimeInputs = [];

  text = ''
    # Restart script for kde
    killall -9 .plasmashell-wr
    plasmashell --replace&
  '';
}
