{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.cloak;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.cloak.enable =
    lib.mkEnableOption "cloak plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.cloak = {
      enable = true;

      settings = {
        patterns = [
          { file_pattern = ".env*"; cloak_pattern = "=.+"; }
          {
            file_pattern = "services.json";
            cloak_pattern = [
              ''(pass": ")[^"]*''
              ''(password": ")[^"]*''
            ];
            replace = "%1";
          }
        ];
      };
    };
  };
}
