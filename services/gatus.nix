{ config, pkgs, ... }:

{
  sops.secrets.gatus-ntfy-token = { };
  sops.secrets.mailbox-smtp-password = { };
  sops.secrets.healthchecks-ping-url = { };

  sops.templates."gatus-env".content = ''
    GATUS_NTFY_TOKEN=${config.sops.placeholder.gatus-ntfy-token}
    GATUS_SMTP_PASSWORD=${config.sops.placeholder.mailbox-smtp-password}
    HEALTHCHECKS_PING_URL=${config.sops.placeholder.healthchecks-ping-url}
  '';

  services.gatus = {
    enable = true;
    environmentFile = config.sops.templates."gatus-env".path;

    settings = {
      alerting = {
        email = {
          from = "ryan@ryanmalonzo.com";
          username = "ryan@ryanmalonzo.com";
          password = "$GATUS_SMTP_PASSWORD";
          host = "smtp.mailbox.org";
          port = 587;
          to = "alerts@ryanmalonzo.com";
          default-alert = {
            send-on-resolved = true;
            failure-threshold = 3;
            success-threshold = 2;
          };
        };
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
          name = "Gonic";
          group = "media-streaming";
          url = "https://music.chaldea.dev/rest/ping.view?f=json";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Jellyfin";
          group = "media-streaming";
          url = "http://jellyfin.internal.chaldea.dev/health";
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
          name = "Seerr";
          group = "media-management";
          url = "https://seerr.internal.chaldea.dev/api/v1/status";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Immich";
          group = "photos";
          url = "https://photos.chaldea.dev/api/server/ping";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "FileFlows";
          group = "media-management";
          url = "https://fileflows.internal.chaldea.dev/api/status";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Healthchecks.io";
          group = "infrastructure";
          url = "$HEALTHCHECKS_PING_URL";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "ntfy";
          group = "infrastructure";
          url = "https://push.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "email"; } ];
        }
        {
          name = "Technitium DNS Server";
          group = "infrastructure";
          url = "https://dns.internal.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Actual";
          group = "finance";
          url = "https://actual.internal.chaldea.dev/health";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Papra";
          group = "documents";
          url = "https://papra.internal.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "BentoPDF";
          group = "utilities";
          url = "https://pdf.chaldea.dev";
          interval = "30s";
          conditions = [ "[STATUS] == 200" ];
          alerts = [ { type = "ntfy"; } ];
        }
        {
          name = "Wallos";
          group = "finance";
          url = "https://wallos.internal.chaldea.dev";
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
