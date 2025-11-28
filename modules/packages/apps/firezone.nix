{ config, lib, ... }:
let
  cfg = config.modules.packages.apps.firezone;
  enable = cfg.enable;
in {
  options.modules.packages.apps.firezone.enable =
    lib.mkEnableOption "firezone";

  config = lib.mkIf enable {

    services.firezone = {
      gui-client = {
        enable = true;
        name = "Stian - Deimos";
        allowedUsers = [ "otard" ];
      };
      # headless-client = {
      #   enable = true;
      #   name = "Stian - Deimos CLI";
      #   apiUrl = "wss://app.firezone.dev/<id>/";
      #   tokenFile = "/home/otard/firezone-secret"; # TODO: Fix this
      # };
    };

    modules.system.networking.resolved.enable = true;

  };
}
