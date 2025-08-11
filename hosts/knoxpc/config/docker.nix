{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}:
{
  # Primary user configurations for virtualisation
  users.users.${primaryUser} = {
    uid = 1000; # Explicitly named for usage in setting up containers
    group = toString primaryUser;
    extraGroups = [ "podman" ];
  };
  # Explicitly named for usage in setting up containers
  users.groups.${primaryUser}.gid = 1001;

  # Base ports
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.eth0.forwarding" = 1; # enable port forwarding
  };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
    autoPrune.enable = true;

    # Docker Compats
    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;
    # Make the Podman socket available in place of the Docker socket, so Docker tools can find the Podman socket.
    dockerSocket.enable = true;
    #networkSocket.enable = true;
  };

  virtualisation.oci-containers.backend = "podman";

  # Attempt at Rootless docker
  # virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "btrfs";
  # virtualisation.docker.autoPrune.enable = true;
  # virtualisation.docker.daemon.settings = {
  #   data-root = "/var/lib/containers";
  # };
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true; # Set DOCKER\_HOST for rootless Docker
  # };
  #
  # virtualisation.oci-containers.backend = "docker";
}
