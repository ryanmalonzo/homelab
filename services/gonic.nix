{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/gonic/cache 0755 1000 100 -"
    "d /srv/gonic/data 0755 1000 100 -"
    "d /srv/gonic/podcasts 0755 1000 100 -"
    "d /srv/gonic/playlists 0755 1000 100 -"
    "d /tank/music 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.gonic = {
    image = "ghcr.io/sentriz/gonic:v0.20.1";
    user = "1000:100";
    ports = [ "4747" ];
    volumes = [
      "/srv/gonic/cache:/cache"
      "/srv/gonic/data:/data"
      "/srv/gonic/podcasts:/podcasts"
      "/srv/gonic/playlists:/playlists"
      "/tank/music:/music:ro"
    ];
    environment = {
      GONIC_LISTEN_ADDR = "0.0.0.0:4747";
      TZ = "Europe/Paris";
    };
  };
}
