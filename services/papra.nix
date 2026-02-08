{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/papra/db 0755 1000 100 -"
    "d /tank/documents/papra 0755 1000 100 -"
  ];

  sops.secrets = {
    papra-auth-secret = { };
  };
  sops.templates."papra-env" = {
    content = ''
      AUTH_SECRET=${config.sops.placeholder.papra-auth-secret}
      APP_BASE_URL=https://papra.chaldea.dev
    '';
  };

  virtualisation.oci-containers.containers.papra = {
    image = "ghcr.io/papra-hq/papra:26.1.0-rootless";
    user = "1000:100";
    ports = [ "1221" ];
    volumes = [
      "/srv/papra/db:/app/app-data/db"
      "/tank/documents/papra:/app/app-data/documents"
    ];
    environmentFiles = [
      config.sops.templates."papra-env".path
    ];
  };
}
