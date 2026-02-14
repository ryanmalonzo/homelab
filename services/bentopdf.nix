{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers.bentopdf = {
    image = "ghcr.io/alam00000/bentopdf-simple:2.2.1";
    ports = [ "8080" ];
  };
}
