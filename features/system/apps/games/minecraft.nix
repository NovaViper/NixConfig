{
  config,
  lib,
  pkgs,
  ...
}: let
  cfgFeat = config.features;
in {
  environment.systemPackages = with pkgs; [
    # Minecraft
    prismlauncher
    flite
    orca
  ];

  # Allow Minecraft server ports
  networking.firewall.allowedTCPPorts = lib.mkIf cfgFeat.includeMinecraftServer [25565 24454];

  hmUser = lib.singleton {
    programs.java.enable = true;

    home.shellAliases = lib.mkIf cfgFeat.includeMinecraftServer {
      start-minecraft-server = "cd ~/Games/MinecraftServer-1.21.x/ && ./run.sh --nogui && cd || cd";
      start-minecraft-server-1-20 = "cd ~/Games/MinecraftServer-1.20.1/ && ./run.sh --nogui && cd || cd";
      start-minecraft-fabric-server = "cd ~/Games/MinecraftFabricServer-1.20.1/ && java -Xmx8G -jar ./fabric-server-mc.1.20.1-loader.0.15.7-launcher.1.0.0.jar nogui && cd || cd";
    };
  };
}
