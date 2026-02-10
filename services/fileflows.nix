{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/fileflows 0755 1000 100 -"
    "d /srv/fileflows/temp 0755 1000 100 -"
    "d /srv/fileflows/Data 0755 1000 100 -"
    "d /srv/fileflows/Logs 0755 1000 100 -"
    "d /srv/fileflows/common 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.fileflows = {
    image = "revenz/fileflows:stable";
    ports = [ "5000:5000" ];
    volumes = [
      "/srv/fileflows/temp:/temp"
      "/srv/fileflows/Data:/app/Data"
      "/srv/fileflows/Logs:/app/Logs"
      "/srv/fileflows/common:/app/common"
      "/tank/media/anime/tv:/media/anime/tv"
      "/tank/media/anime/movies:/media/anime/movies"
    ];
    environment = {
      TempPathHost = "/srv/fileflows/temp";
      TZ = "Europe/Paris";
      PUID = "1000";
      PGID = "100";
    };
    extraOptions = [
      "--device=/dev/dri:/dev/dri"
    ];
  };
}
