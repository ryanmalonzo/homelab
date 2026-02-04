{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    package = pkgs.zfs_unstable;
    forceImportRoot = false;
    extraPools = [ "tank" ];
  };

  networking.hostId = "637816ff";
}
