{ config, pkgs, ... }:

{
  services.technitium-dns-server = {
    enable = true;
    package = pkgs.technitium-dns-server;
    openFirewall = false;
  };

  networking.firewall = {
    allowedTCPPorts = [
      53
      5380
    ];
    allowedUDPPorts = [ 53 ];
  };
}
