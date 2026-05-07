{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.satty;
  enable = cfg.enable;
in {
  options.modules.packages.satty = {
    enable = lib.mkEnableOption "satty";
  };

  config = lib.mkIf enable {
    home.packages = [ pkgs.grimblast pkgs.wl-clipboard ];

    programs.satty = {
      enable = true;

      settings = {
        general = {
          early-exit = true;
          initial-tool = "arrow";
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
        exec = "uwsm app -- grimblast save area - | satty --filename -";
      }
    ];
  };
}

