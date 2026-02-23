{ pkgs, lib, ... }:

let
  networks = [
    "actual"
    "arr"
    "fileflows"
    "immich"
    "papra"
    "proxy"
  ];
in
{
  systemd.services = lib.listToAttrs (
    map (
      name:
      lib.nameValuePair "podman-network-${name}" {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman network inspect ${lib.escapeShellArg name} \
            || podman network create ${lib.escapeShellArg name}
        '';
        wantedBy = [ "multi-user.target" ];
      }
    ) networks
  );
}
