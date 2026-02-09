{ config, pkgs, ... }:

{
  sops.secrets.github-runner-token = {
    owner = "github-runner";
  };

  services.github-runners.chaldea = {
    enable = true;
    url = "https://github.com/ryanmalonzo/homelab";
    tokenFile = config.sops.secrets.github-runner-token.path;
    user = "github-runner";
    extraLabels = [
      "nixos"
      "homelab"
    ];
    extraPackages = with pkgs; [
      git
      terraform
      gh
      openssh
      xz
    ];
  };

  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups.github-runner = { };
}
