{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.satty;
  enable = cfg.enable;
in {
  options.modules.packages.satty = {
    enable = lib.mkEnableOption "satty";
  };

  config = lib.mkIf enable {
    home.packages = [ pkgs.grim pkgs.wl-clipboard ];

    programs.satty = {
      enable = true;

      settings = {
        general = {
          fullscreen = "all";
          early-exit = true;
          initial-tool = "crop";
          copy-command = "wl-copy";
          annotation-size-factor = 2;
          corner-roundness = 12;
          actions-on-enter = [ "save-to-clipboard" ];
          actions-on-escape = [ "exit" ];
          default-fill-shapes = false;
          default-hide-toolbars = false;
          primary-highlighter = "block";
          brush-smooth-history-size = 5;
        };
      };
    };

    modules.desktopEnvironment.keybinds = [
      {
        key = "s";
        mods = [ "main" "shift" ];
        exec = "uwsm app -- grim -o \$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name') -t png - | satty --filename -";
      }
    ];
  };
}

