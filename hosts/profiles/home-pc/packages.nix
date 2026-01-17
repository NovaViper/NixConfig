{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    webcamoid
    bottles
    solaar # Logitech manager
  ];
}
