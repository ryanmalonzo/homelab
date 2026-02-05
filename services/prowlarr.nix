{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/prowlarr/config 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.prowlarr = {
    image = "ghcr.io/linuxserver/prowlarr:2.3.0";
    user = "1000:100";
    ports = [ "9696:9696" ];
    volumes = [
      "/srv/prowlarr/config:/config"
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Paris";
    };
  };
}
