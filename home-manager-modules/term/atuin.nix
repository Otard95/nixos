{ config, lib, ... }:
let
  cfg = config.modules.term.atuin;
  enable = cfg.enable;
in {
  options.modules.term.atuin.enable =
    lib.mkEnableOption "atuin";

  config = lib.mkIf enable {

    programs.atuin = {
      enable = true;
      daemon.enable = true;
      flags = [ "--disable-up-arrow" ];

      settings = {
        auto_sync = false;
        search_mode = "daemon-fuzzy";
      };
    };

  };
}
