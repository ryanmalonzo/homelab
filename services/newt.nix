{ config, pkgs, ... }:

{
  sops.secrets = {
    pangolin-endpoint = { };
    newt-id = { };
    newt-secret = { };
  };
  sops.templates."newt-env" = {
    content = ''
      PANGOLIN_ENDPOINT=${config.sops.placeholder.pangolin-endpoint}
      NEWT_ID=${config.sops.placeholder.newt-id}
      NEWT_SECRET=${config.sops.placeholder.newt-secret}
    '';
  };

  virtualisation.oci-containers.containers.newt = {
    image = "ghcr.io/fosrl/newt:1.10.0";
    networks = [ "proxy" ];
    environmentFiles = [
      config.sops.templates."newt-env".path
    ];
  };

  systemd.services."podman-newt".after = [ "podman-network-proxy.service" ];
  systemd.services."podman-newt".requires = [ "podman-network-proxy.service" ];
  systemd.services."podman-newt".restartTriggers = [
    config.sops.templates."newt-env".file
  ];
}
