{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/vaultwarden/data 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "ghcr.io/dani-garcia/vaultwarden:1.35.3";
    user = "1000:100";
    networks = [ "proxy" ];
    volumes = [
      "/srv/vaultwarden/data:/data"
    ];
    environment = {
      DOMAIN = "https://vaultwarden.chaldea.dev";
      ROCKET_PORT = "8080";
      SIGNUPS_ALLOWED = "false";
    };
  };

  systemd.services."podman-vaultwarden".after = [ "podman-network-proxy.service" ];
  systemd.services."podman-vaultwarden".requires = [ "podman-network-proxy.service" ];
}
