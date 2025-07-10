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

    wayland.windowManager.hyprland.settings.bind =
      lib.mkIf config.modules.desktopEnvironment.hyprland.wm.enable [
        "ALT+CTRL, V, exec, uwsm app -- rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"
      ];

  };
}
