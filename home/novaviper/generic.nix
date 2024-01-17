{ lib, ... }: {
  imports = [ ./global ];

  ### Special Variables
  variables.desktop.environment = "kde";
  ###

  theme = lib.mkForce { };

  # Disable impermanence
  #home.persistence = lib.mkForce { };
}
