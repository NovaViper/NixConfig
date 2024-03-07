{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports = [ ../common/global ./features/cli ./features/neovim ];

  ### Special Variables
  variables.desktop.environment = "kde";
  variables.desktop.displayManager = "wayland";
  ###

  # Enable HTML help page
  manual.html.enable = true;

  # Setup Home-Manager
  home = {
    username = lib.mkDefault "nixos";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
    sessionPath = [ "$HOME/.local/bin" ];
    packages = with pkgs; [ kitty ];
  };

  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = "org.kde.breezedark.desktop";
  };

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = with pkgs; [
      fx-cast-bridge
      kdePackages.plasma-browser-integration
    ];
    profiles.default = {
      id = 0;
      search = {
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Wiki" = {
            urls = [{
              template = "https://nixos.wiki/index.php?search={searchTerms}";
            }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
        };
      };
    };
  };
}
