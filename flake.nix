{
  description = "chaldea";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      determinate,
      sops-nix,
    }:
    {
      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      };

      nixosConfigurations.chaldea = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          determinate.nixosModules.default
          sops-nix.nixosModules.sops
          ./configuration.nix
          ./modules/networking.nix
          ./modules/dns.nix
          ./modules/zfs.nix
          ./modules/virtualisation.nix
          ./modules/backups.nix
          ./modules/caddy.nix
          ./modules/hardware-transcoding.nix
          ./services/jellyfin.nix
          ./services/newt.nix
          ./services/vaultwarden.nix
          ./services/sonarr.nix
          ./services/sabnzbd.nix
          ./services/profilarr.nix
          ./services/prowlarr.nix
          ./services/radarr.nix
          ./services/jellyseerr.nix
          ./services/papra.nix
          ./services/bentopdf.nix
          ./services/gonic.nix
          ./services/github-runner.nix
          ./services/ntfy.nix
          ./services/immich.nix
          ./services/gatus.nix
          ./services/fileflows.nix
          ./services/actual.nix
        ];
      };
    };
}
