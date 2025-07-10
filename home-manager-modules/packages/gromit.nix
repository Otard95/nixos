{ config, lib, ... }:
let
  cfg = config.modules.packages.gromit;
  enable = cfg.enable;
in {
  options.modules.packages.gromit.enable =
    lib.mkEnableOption "gromit";

  config = lib.mkIf enable {
    services.gromit-mpx = {
      enable = true;
    };

    systemd.user.services.gromit-mpx = lib.mkForce {};
  };
}
