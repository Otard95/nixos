{ config, lib, ... }:
let
  cfg = config.modules.packages.docker;
  enable = cfg.enable;
in {
  options.modules.packages.docker.enable =
    lib.mkEnableOption "docker";

  config = lib.mkIf enable {
    virtualisation.docker.enable = true;
    users.users.otard.extraGroups = [ "docker" ];
  };
}
