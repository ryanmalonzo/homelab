{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/ntfy/cache 0755 1000 100 -"
    "d /srv/ntfy/etc 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.ntfy = {
    image = "binwiederhier/ntfy:v2.16.0";
    user = "1000:100";
    cmd = [ "serve" ];
    ports = [ "80" ];
    volumes = [
      "/srv/ntfy/cache:/var/cache/ntfy"
      "/srv/ntfy/etc:/etc/ntfy"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
    extraOptions = [
      "--cap-add=NET_BIND_SERVICE"
    ];
  };
}
