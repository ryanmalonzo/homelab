{
  description = "chaldea";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix }: {
    nixosConfigurations.chaldea = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        sops-nix.nixosModules.sops
        ./configuration.nix
        ./modules/zfs.nix
        ./modules/virtualisation.nix
        ./modules/backups.nix
        ./services/jellyfin.nix
        ./services/newt.nix
        ./services/vaultwarden.nix
      ];
    };
  };
}
