{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/jellyseerr/config 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.jellyseerr = {
    image = "ghcr.io/fallenbagel/jellyseerr:2.7.3";
    user = "1000:100";
    ports = [ "5055" ];
    volumes = [
      "/srv/jellyseerr/config:/app/config"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
  };
}
