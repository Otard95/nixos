{ config, lib, pkgs, ... }:
let
  cfg = config.modules.system.printing;
  enable = cfg.enable;
in {
  options.modules.system.printing.enable =
    lib.mkEnableOption "printing";

  config = lib.mkIf enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        fxlinuxprint # Office printer (I think)
      ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
