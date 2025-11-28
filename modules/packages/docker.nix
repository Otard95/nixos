{ config, lib, ... }:
let
  cfg = config.modules.packages.docker;
  enable = cfg.enable;
in {
  options.modules.packages.docker.enable =
    lib.mkEnableOption "docker";

  config = lib.mkIf enable {
    virtualisation.docker = {
      enable = true;

      rootless = {
        enable = true;
        setSocketVariable = true;

        daemon.settings = {
          dns = ["10.210.10.1" "10.200.10.1" "1.1.1.2" "1.0.0.2"];
        };
      };
    };
  };
}
