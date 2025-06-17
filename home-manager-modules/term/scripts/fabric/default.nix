{ config, lib, ... }:
let
  cfg = config.modules.term.scripts.fabric;
  enable = cfg.enable;
in {
  options.modules.term.scripts.fabric.enable =
    lib.mkEnableOption "fabric";

  config = lib.mkIf enable {
    home = {
      file = {
        "scripts/ai.sh" = { source = ./ai.sh; executable = true;  };
      };
      shellAliases = {
        ai = "~/scripts/ai.sh";
      };
    };
  };
}
