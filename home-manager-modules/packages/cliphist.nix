{ config, lib, ... }:
let
  cfg = config.modules.packages.cliphist;
  enable = cfg.enable;
in {
  options.modules.packages.cliphist = {
    enable = lib.mkEnableOption "cliphist";
  };

  config = lib.mkIf enable {

    services.cliphist.enable = true;

    modules.desktopEnvironment.keybinds = [
      { key = "v"; mods = [ "ctrl" "alt" ];
        exec = "uwsm app -- rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons";
      }
    ];

  };
}
