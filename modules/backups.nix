{ config, pkgs, ... }:

{
  sops.secrets = {
    restic-password = { };
    b2-account-id = { };
    b2-account-key = { };
  };
  sops.templates."restic-b2-env" = {
    content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.b2-account-id}
      B2_ACCOUNT_KEY=${config.sops.placeholder.b2-account-key}
    '';
  };

  services.restic.backups = {
    system = {
      repository = "b2:chaldea-backups:/system";

      paths = [
        "/etc/nixos"
        "/srv"
        "/var/lib/technitium-dns-server"
      ];

      exclude = [
        "**/cache"
        "**/logs"
        "/srv/downloads"
        "/srv/incomplete-downloads"
      ];

      passwordFile = config.sops.secrets.restic-password.path;
      environmentFile = config.sops.templates."restic-b2-env".path;

      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      initialize = true;
    };
  };
}
