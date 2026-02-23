{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /tank/photos/upload 0755 1000 100 -"
    "d /tank/photos/library 0755 1000 100 -"
    "d /srv/immich/postgres 0755 1000 100 -"
    "d /srv/immich/model-cache 0755 1000 100 -"
  ];

  sops.secrets = {
    immich-db-password = { };
  };

  sops.templates."immich-env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder.immich-db-password}
      DB_PASSWORD=${config.sops.placeholder.immich-db-password}
      DB_USERNAME=postgres
      DB_DATABASE_NAME=immich
      DB_HOSTNAME=immich-postgres
      DB_PORT=5432
      REDIS_HOSTNAME=immich-redis
      REDIS_PORT=6379
      UPLOAD_LOCATION=/usr/src/app/upload
      TZ=Europe/Paris
      IMMICH_PORT=2283
      IMMICH_HOST=0.0.0.0
      IMMICH_ENV=production
      MACHINE_LEARNING_HOST=immich-machine-learning
      MACHINE_LEARNING_PORT=3003
    '';
  };

  virtualisation.oci-containers.containers.immich-postgres = {
    image = "ghcr.io/tensorchord/pgvecto-rs:pg14-v0.3.0-rootless";
    user = "1000:100";
    volumes = [
      "/srv/immich/postgres:/var/lib/postgresql/data"
    ];
    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_DB = "immich";
      POSTGRES_INITDB_ARGS = "--data-checksums";
    };
    environmentFiles = [
      config.sops.templates."immich-env".path
    ];
  };

  virtualisation.oci-containers.containers.immich-redis = {
    image = "docker.io/valkey/valkey:9.0.2";
  };

  virtualisation.oci-containers.containers.immich-machine-learning = {
    image = "ghcr.io/immich-app/immich-machine-learning:v2.5.6";
    volumes = [
      "/srv/immich/model-cache:/cache"
    ];
    environment = {
      MACHINE_LEARNING_CACHE_FOLDER = "/cache";
      MACHINE_LEARNING_HOST = "0.0.0.0";
      MACHINE_LEARNING_PORT = "3003";
    };
  };

  virtualisation.oci-containers.containers.immich-server = {
    image = "ghcr.io/immich-app/immich-server:v2.5.6";
    user = "1000:100";
    volumes = [
      "/tank/photos/upload:/usr/src/app/upload"
      "/tank/photos/library:/usr/src/app/library"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environmentFiles = [
      config.sops.templates."immich-env".path
    ];
    dependsOn = [
      "immich-postgres"
      "immich-redis"
      "immich-machine-learning"
    ];
  };

  systemd.services."podman-immich-server".restartTriggers = [
    config.sops.templates."immich-env".file
  ];
  systemd.services."podman-immich-postgres".restartTriggers = [
    config.sops.templates."immich-env".file
  ];
}
