{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/containers/jellyfin/cache 0755 1000 100 -"
    "d /var/lib/containers/jellyfin/config 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.jellyfin = {
    image = "ghcr.io/jellyfin/jellyfin:10.11.6";
    user = "1000:100";
    ports = [ "7359:7359/udp" "8096:8096" ];
    volumes = [
      "/var/lib/containers/jellyfin/config:/config"
      "/var/lib/containers/jellyfin/cache:/cache"
      "/tank/media/anime/tv:/data/anime/tv:ro"
      "/tank/media/anime/movies:/data/anime/movies:ro"
      "/tank/media/others/tv:/data/others/tv:ro"
      "/tank/media/others/movies:/data/others/movies:ro"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8096 ];
  networking.firewall.allowedUDPPorts = [ 7359 ];
}
