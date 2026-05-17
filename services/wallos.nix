{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/wallos/db 0755 1000 100 -"
    "d /srv/wallos/logos 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.wallos = {
    image = "ghcr.io/ellite/wallos:4.9.0";
    networks = [ "wallos" ];
    ports = [ "8282:80" ];
    volumes = [
      "/srv/wallos/db:/var/www/html/db"
      "/srv/wallos/logos:/var/www/html/images/uploads/logos"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
  };

  systemd.services."podman-wallos".after = [ "podman-network-wallos.service" ];
  systemd.services."podman-wallos".requires = [ "podman-network-wallos.service" ];
}
