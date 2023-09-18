{ inputs, lib, config, ... }:

{
  disabledModules = [ "security/pam.nix" ];
  imports = [
    "${inputs.nixpkgs-howdy}/nixos/modules/security/pam.nix"
    "${inputs.nixpkgs-howdy}/nixos/modules/services/security/howdy"
    "${inputs.nixpkgs-howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
  ];

  services = {
    howdy = {
      enable = true;
      package = inputs.nixpkgs-howdy.legacyPackages.x86_64-linux.howdy;
      settings = {
        video.device_path = "/dev/video2";
        # you may not need these
        core.no_confirmation = true;
        video.dark_threshold = 90;
      };
    };

    # in case your IR blaster does not blink, run `sudo linux-enable-ir-emitter configure`
    linux-enable-ir-emitter = {
      enable = true;
      device = "video2";
      package =
        inputs.nixpkgs-howdy.legacyPackages.x86_64-linux.linux-enable-ir-emitter;
    };
  };

  #security.pam.services.howdy.enableKwallet = lib.mkDefault config.services.xserver.desktopManager.plasma5.enable;
}
