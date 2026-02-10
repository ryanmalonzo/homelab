{ config, pkgs, ... }:

let
  tlsConfig = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      resolvers 1.1.1.1
    }
  '';
in
{
  services.tailscale.permitCertUid = "caddy";

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
      hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
    };

    virtualHosts = {
      "sonarr.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:8989
        '';
      };
      "sabnzbd.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:8080
        '';
      };
      "prowlarr.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:9696
        '';
      };
      "profilarr.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:6868
        '';
      };
      "radarr.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:7878
        '';
      };
      "dns.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:5380
        '';
      };
      "status.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:8085
        '';
      };
      "fileflows.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:5000
        '';
      };
      "actual.internal.chaldea.dev" = {
        extraConfig = ''
          ${tlsConfig}
          reverse_proxy localhost:5006
        '';
      };
    };
  };

  sops.secrets.cloudflare-api-token = {
    owner = "caddy";
  };

  sops.templates."caddy-env".content = ''
    CLOUDFLARE_API_TOKEN=${config.sops.placeholder.cloudflare-api-token}
  '';

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env".path;
}
