{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers.bentopdf = {
    image = "ghcr.io/alam00000/bentopdf-simple:2.3.3";
    networks = [ "proxy" ];
  };

  systemd.services."podman-bentopdf".after = [ "podman-network-proxy.service" ];
  systemd.services."podman-bentopdf".requires = [ "podman-network-proxy.service" ];
}
