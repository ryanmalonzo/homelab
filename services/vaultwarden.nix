{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/vaultwarden/data 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "ghcr.io/dani-garcia/vaultwarden:1.35.3";
    user = "1000:100";
    volumes = [
      "/srv/vaultwarden/data:/data"
    ];
    environment = {
      DOMAIN = "https://vaultwarden.chaldea.dev";
      ROCKET_PORT = "8080";
      SIGNUPS_ALLOWED = "false";
    };
  };
}
