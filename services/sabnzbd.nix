{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/sabnzbd/config 0755 1000 100 -"
    "d /srv/downloads 0755 1000 100 -"
    "d /srv/incomplete-downloads 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.sabnzbd = {
    image = "ghcr.io/linuxserver/sabnzbd:4.5.5";
    user = "1000:100";
    ports = [ "8080:8080" ];
    volumes = [
      "/srv/sabnzbd/config:/config"
      "/srv/downloads:/downloads"
      "/srv/incomplete-downloads:/incomplete-downloads"
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Paris";
    };
  };
}
