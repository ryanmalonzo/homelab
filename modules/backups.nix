{ config, pkgs, ... }:

{
  sops.secrets = {
    restic_password = { };
    b2_account_id = { };
    b2_account_key = { };
  };
  sops.templates."restic-b2-env" = {
    content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.b2_account_id}
      B2_ACCOUNT_KEY=${config.sops.placeholder.b2_account_key}
    '';
  };

  services.restic.backups = {
    system = {
      repository = "b2:chaldea-backups:/system";

      paths = [
        "/etc/nixos"
        "/var/lib/containers"
      ];

      passwordFile = config.sops.secrets.restic_password.path;
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
