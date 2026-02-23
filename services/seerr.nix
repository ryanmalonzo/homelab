{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/seerr/config 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.seerr = {
    image = "ghcr.io/seerr-team/seerr:v3.0.1";
    networks = [
      "arr"
      "proxy"
    ];
    volumes = [
      "/srv/seerr/config:/app/config"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
    extraOptions = [ "--init" ];
  };

  systemd.services."podman-seerr".after = [
    "podman-network-arr.service"
    "podman-network-proxy.service"
  ];
  systemd.services."podman-seerr".requires = [
    "podman-network-arr.service"
    "podman-network-proxy.service"
  ];
}
