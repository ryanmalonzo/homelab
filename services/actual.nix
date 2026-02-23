{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/actual/data 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.actual = {
    image = "ghcr.io/actualbudget/actual:26.2.1";
    user = "1000:100";
    networks = [ "actual" ];
    ports = [ "5006:5006" ];
    volumes = [
      "/srv/actual/data:/data"
    ];
  };

  systemd.services."podman-actual".after = [ "podman-network-actual.service" ];
  systemd.services."podman-actual".requires = [ "podman-network-actual.service" ];
}
