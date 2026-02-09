{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/ntfy 0755 1000 100 -"
  ];

  sops.secrets = {
    ntfy-auth-users = { };
  };
  sops.templates."ntfy-env" = {
    content = ''
      NTFY_ATTACHMENT_CACHE_DIR=/var/lib/ntfy/attachments
      NTFY_AUTH_DEFAULT_ACCESS=deny-all
      NTFY_AUTH_FILE=/var/lib/ntfy/auth.db
      NTFY_AUTH_USERS=${config.sops.placeholder.ntfy-auth-users}
      NTFY_BASE_URL=https://push.chaldea.dev
      NTFY_BEHIND_PROXY=true
      NTFY_CACHE_FILE=/var/lib/ntfy/cache.db
      NTFY_ENABLE_LOGIN=true
      NTFY_UPSTREAM_BASE_URL=https://ntfy.sh
      NTFY_WEB_PUSH_FILE=/var/lib/ntfy/webpush.db
      TZ=Europe/Paris
    '';
  };

  virtualisation.oci-containers.containers.ntfy = {
    image = "binwiederhier/ntfy:v2.16.0";
    user = "1000:100";
    cmd = [ "serve" ];
    ports = [ "80" ];
    volumes = [
      "/srv/ntfy:/var/lib/ntfy"
    ];
    environmentFiles = [
      config.sops.templates."ntfy-env".path
    ];
    extraOptions = [
      "--cap-add=NET_BIND_SERVICE"
    ];
  };

  systemd.services."podman-ntfy".restartTriggers = [
    config.sops.templates."ntfy-env".file
  ];
}
