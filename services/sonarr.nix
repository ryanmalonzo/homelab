{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/sonarr/config 0755 1000 100 -"
    "d /srv/downloads 0755 1000 100 -"
    "d /tank/media/anime/tv 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.sonarr = {
    image = "ghcr.io/linuxserver/sonarr:4.0.16";
    user = "1000:100";
    networks = [ "arr" ];
    ports = [ "8989:8989" ];
    volumes = [
      "/srv/sonarr/config:/config"
      "/srv/downloads:/downloads"
      "/tank/media/anime/tv:/tv"
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Paris";
    };
  };

  systemd.services."podman-sonarr".after = [ "podman-network-arr.service" ];
  systemd.services."podman-sonarr".requires = [ "podman-network-arr.service" ];
}
