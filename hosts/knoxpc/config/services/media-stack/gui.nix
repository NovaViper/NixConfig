{
  config,
  pkgs,
  lib,
  inputs,
  myLib,
  ...
}:
let
  # Keys come from sops/hosts/knoxpc/arrs.yaml. An unpublished secrets checkout
  # can be selected with --override-input nix-secrets path:/path/to/nix-secrets.
  gui = {
    enable = true;
    dryRun = false;
    lidarrQualityProfile = "Any";
    lidarrMetadataProfile = "Standard";
  };
  # Values are resolved by Configarr at runtime, never embedded in the Nix store.
  secretNames = {
    SONARR_API_KEY = "sonarr-api-key";
    RADARR_API_KEY = "radarr-api-key";
    LIDARR_API_KEY = "lidarr-api-key";
    PROWLARR_API_KEY = "prowlarr-api-key";
    QBITTORRENT_API_KEY = "qbittorrent-api-key";
  };
  secretRef = name: "__CONFIGARR_ENV_${name}__";
  appUrl = name: "http://127.0.0.1:${toString config.services.${name}.settings.server.port}";
  downloadClient = category: categoryField: {
    data = [
      {
        name = "qBittorrent";
        type = "QBittorrent";
        enable = true;
        fields = {
          host = "127.0.0.1";
          port = config.services.qbittorrent.webuiPort;
          use_ssl = false;
          url_base = "";
          username = "";
          password = "";
          api_key = secretRef "QBITTORRENT_API_KEY";
          ${categoryField} = category;
        };
      }
    ];
    update_password = true;
    delete_unmanaged.enabled = false;
  };
  guiSettings = {
    telemetry = false;
    sonarr.knoxpc = {
      base_url = appUrl "sonarr";
      api_key = secretRef "SONARR_API_KEY";
      root_folders = [ "/storage/media/Library/Shows" ];
      download_clients = downloadClient "sonarr" "tv_category";
    };
    radarr.knoxpc = {
      base_url = appUrl "radarr";
      api_key = secretRef "RADARR_API_KEY";
      root_folders = [ "/storage/media/Library/Movies" ];
      download_clients = downloadClient "radarr" "movie_category";
    };
    lidarr.knoxpc = {
      base_url = appUrl "lidarr";
      api_key = secretRef "LIDARR_API_KEY";
      root_folders = [
        {
          name = "Music";
          path = "/storage/media/Library/Music";
          quality_profile = gui.lidarrQualityProfile;
          metadata_profile = gui.lidarrMetadataProfile;
          monitor = "none";
          monitor_new_album = "none";
        }
      ];
      download_clients = downloadClient "lidarr" "music_category";
    };
    prowlarr.knoxpc = {
      base_url = appUrl "prowlarr";
      api_key = secretRef "PROWLARR_API_KEY";
      tags = [ "flaresolverr" ];
      sync_profiles = {
        data = [
          {
            name = "Standard";
            enable_rss = true;
            enable_automatic_search = true;
            enable_interactive_search = true;
            minimum_seeders = 1;
          }
        ];
        delete_unmanaged.enabled = false;
      };
      indexer_proxies = {
        data = [
          {
            name = "FlareSolverr";
            type = "FlareSolverr";
            fields.host = "http://127.0.0.1:${toString config.services.flaresolverr.port}/";
            tags = [ "flaresolverr" ];
          }
        ];
        delete_unmanaged.enabled = false;
      };
      applications = {
        data =
          map
            (name: {
              name =
                {
                  sonarr = "Sonarr";
                  radarr = "Radarr";
                  lidarr = "Lidarr";
                }
                .${name};
              type =
                {
                  sonarr = "Sonarr";
                  radarr = "Radarr";
                  lidarr = "Lidarr";
                }
                .${name};
              sync_level = "fullSync";
              fields = {
                prowlarrUrl = appUrl "prowlarr";
                baseUrl = appUrl name;
                apiKey = secretRef "${lib.toUpper name}_API_KEY";
              };
            })
            [
              "sonarr"
              "radarr"
              "lidarr"
            ];
        delete_unmanaged.enabled = false;
        sync_indexers = true;
      };
    };
  };
  # JSON flow syntax is valid YAML. Replace only complete secret-reference
  # strings with YAML !env tags, leaving every other value JSON-escaped.
  configarrYaml = builtins.replaceStrings (map (name: builtins.toJSON (secretRef name)) (
    builtins.attrNames secretNames
  )) (map (name: " !env ${name}") (builtins.attrNames secretNames)) (builtins.toJSON guiSettings);
in
{
  imports = [ inputs.configarr.nixosModules.default ];

  services = {
    configarr = lib.mkIf gui.enable {
      enable = true;
      package = pkgs.configarr;
      config = configarrYaml;
      environmentFile = config.sops.templates."arrs.env".path;
      schedule = "daily";
    };
  }
  // lib.genAttrs [ "sonarr" "radarr" "lidarr" "prowlarr" ] (name: {
    # Pin each app's own key to the same secret used by Configarr.
    environmentFiles = lib.mkIf gui.enable [ config.sops.templates."${name}-api-key.env".path ];
  });

  sops.secrets = lib.mkIf gui.enable (
    lib.genAttrs (builtins.attrValues secretNames) (
      _:
      myLib.secrets.mkSecretFile {
        source = "arrs.yaml";
        subDir = [
          "hosts"
          config.networking.hostName
        ];
      }
    )
  );
  sops.templates = lib.mkIf gui.enable (
    {
      "arrs.env" = {
        content = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            envName: secretName: "${envName}=${config.sops.placeholder.${secretName}}"
          ) secretNames
        );
        restartUnits = [ "configarr.service" ];
      };
      # qBittorrent regenerates its configuration on restart. Preserve the same
      # API key used by the three applications, alongside its existing password.
      qbittorrent-password-config.content = lib.mkAfter ''
        APIKey=${config.sops.placeholder.qbittorrent-api-key}
      '';
    }
    //
      lib.genAttrs
        [ "sonarr-api-key.env" "radarr-api-key.env" "lidarr-api-key.env" "prowlarr-api-key.env" ]
        (
          file:
          let
            name = lib.removeSuffix "-api-key.env" file;
          in
          {
            content = "${lib.toUpper name}__AUTH__APIKEY=${config.sops.placeholder."${name}-api-key"}\n";
            restartUnits = [ "${name}.service" ];
          }
        )
  );

  systemd.services.configarr = lib.mkIf gui.enable {
    after = [
      "sonarr.service"
      "radarr.service"
      "lidarr.service"
      "prowlarr.service"
      "qbittorrent.service"
      "flaresolverr.service"
    ];
    wants = [
      "sonarr.service"
      "radarr.service"
      "lidarr.service"
      "prowlarr.service"
      "qbittorrent.service"
      "flaresolverr.service"
    ];
    environment = {
      DRY_RUN = lib.boolToString gui.dryRun;
      TELEMETRY_ENABLED = "false";
      STOP_ON_ERROR = "true";
    };
  };
}
