{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment.uwsm;
  enable = cfg.enable;

  mkStrOption = name: lib.mkOption {
    type = lib.types.str;
    description = name;
  };
in {

  options.modules.desktopEnvironment.uwsm = {
    enable = lib.mkEnableOption "hyprland configuration";

    envs = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = mkStrOption "Environment Variable Name";
          value = mkStrOption "Environment Variable Value";
        };
      });
      description = "The Environment Variables to set for the session";
    };
  };

  config = lib.mkIf enable {
    xdg.configFile."uwsm/env".text =
      lib.concatLines (builtins.map ({ name, value }: "export ${name}=${value}") cfg.envs);
  };
}
