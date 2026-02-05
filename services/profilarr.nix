{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/profilarr/config 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.profilarr = {
    image = "santiagosayshey/profilarr:v1.1.4";
    ports = [ "6868:6868" ];
    volumes = [
      "/srv/profilarr/config:/config"
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Paris";
    };
  };
}
