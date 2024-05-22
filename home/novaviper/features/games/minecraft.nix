{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [prismlauncher flite orca];

  home.shellAliases = {
    start-minecraft-server = "cd ~/Games/MinecraftServer-1.20.1/ && ./run.sh --nogui && cd || cd";
    start-minecraft-fabric-server = "cd ~/Games/MinecraftFabricServer-1.20.1/ && java -Xmx8G -jar ./fabric-server-mc.1.20.1-loader.0.15.7-launcher.1.0.0.jar nogui && cd || cd";
  };
}
