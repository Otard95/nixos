{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.podman;
  enable = cfg.enable;
in {
  options.modules.packages.podman.enable =
    lib.mkEnableOption "podman";

  config = lib.mkIf enable {

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = false;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    # Useful other development tools
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      # docker-compose # start group of containers for dev
      podman-compose # start group of containers for dev
    ];

  };
}
