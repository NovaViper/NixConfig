{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    webcamoid
    bottles
  ];
}
