{ config, pkgs, ... }:

{
  sops.secrets = {
    pangolin_endpoint = { };
    newt_id = { };
    newt_secret = { };
  };
  sops.templates."newt-env" = {
    content = ''
      PANGOLIN_ENDPOINT=${config.sops.placeholder.pangolin_endpoint}
      NEWT_ID=${config.sops.placeholder.newt_id}
      NEWT_SECRET=${config.sops.placeholder.newt_secret}
    '';
  };

  virtualisation.oci-containers.containers.newt = {
    image = "ghcr.io/fosrl/newt:1.9.0";
    environmentFiles = [
      config.sops.templates."newt-env".path
    ];
  };
}
