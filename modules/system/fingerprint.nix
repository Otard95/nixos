{ config, lib, ... }:
let
  cfg = config.modules.system.fingerprint;
  enable = cfg.enable;
in {
  options.modules.system.fingerprint.enable =
    lib.mkEnableOption "fingerprint";

  config = lib.mkIf enable {

    services.fprintd = {
      enable = true;
    };

    systemd.services.fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };

  };
}
