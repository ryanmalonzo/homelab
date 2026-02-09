{ config, pkgs, ... }:

{
  sops.secrets.gatus-ntfy-token = { };

  sops.templates."gatus-env".content = ''
    GATUS_NTFY_TOKEN=${config.sops.placeholder.gatus-ntfy-token}
  '';

  services.gatus = {
    enable = true;
    environmentFile = config.sops.templates."gatus-env".path;

    settings = {
      alerting = {
        ntfy = {
          topic = "gatus";
          url = "https://push.chaldea.dev";
          priority = 4;
          token = "$GATUS_NTFY_TOKEN";
          default-alert = {
            send-on-resolved = true;
            failure-threshold = 3;
            success-threshold = 2;
          };
        };
      };

      endpoints = [
        {
          name = "Jellyfin";
          group = "media-streaming";
          url = "http://jellyfin.chaldea.dev/health";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Sonarr";
          group = "media-management";
          url = "https://sonarr.internal.chaldea.dev/ping";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Radarr";
          group = "media-management";
          url = "https://radarr.internal.chaldea.dev/ping";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Prowlarr";
          group = "media-management";
          url = "https://prowlarr.internal.chaldea.dev/ping";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Profilarr";
          group = "media-management";
          url = "https://profilarr.internal.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "SABnzbd";
          group = "media-management";
          url = "https://sabnzbd.internal.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Jellyseerr";
          group = "media-management";
          url = "https://jellyseerr.chaldea.dev/api/v1/status";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Immich";
          group = "media-management";
          url = "https://photos.chaldea.dev/api/server/ping";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Vaultwarden";
          group = "infrastructure";
          url = "https://vaultwarden.chaldea.dev/alive";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [
            {
              type = "ntfy";
              failure-threshold = 2;
            }
          ];
        }
        {
          name = "ntfy";
          group = "infrastructure";
          url = "https://push.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Technitium DNS Server";
          group = "infrastructure";
          url = "https://dns.internal.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
      ];

      web = {
        port = 8085;
      };
    };
  };
}
