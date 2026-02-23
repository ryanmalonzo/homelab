{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/seerr/config 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.seerr = {
    image = "ghcr.io/seerr-team/seerr:v3.0.1";
    volumes = [
      "/srv/seerr/config:/app/config"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
    extraOptions = [ "--init" ];
  };
}
