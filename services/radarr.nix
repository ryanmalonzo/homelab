{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/radarr/config 0755 1000 100 -"
    "d /srv/downloads 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.radarr = {
    image = "ghcr.io/linuxserver/radarr:6.0.4";
    user = "1000:100";
    ports = [ "7878:7878" ];
    volumes = [
      "/srv/radarr/config:/config"
      "/srv/downloads:/downloads"
      "/tank/media/anime/movies:/movies"
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Paris";
    };
  };
}
