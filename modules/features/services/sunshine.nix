{
  config,
  lib,
  ...
}:
lib.utilMods.mkDesktopModule config "sunshine-server" {
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    /*
      settings = {
      sunshine_name = "${config.networking.hostName}";
    };
    */
    openFirewall = true;
  };
}
