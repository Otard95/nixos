{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.fastfetch;
  enable = cfg.enable;
in {

  options.modules.term.fastfetch.enable = lib.mkEnableOption "fastfetch configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      fastfetch
    ];

    programs = {

      fastfetch = {

        enable = true;

        settings = {
          logo = {
            padding = {
              top = 0;
              left = 4;
            };
          };
          modules = [
            "title"
            "separator"
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "cpu"
            "gpu"
            "memory"
            "swap"
            "disk"
            "localip"
            "locale"
            "break"
            "colors"
          ];
        };

      };

      bash.initExtra = "fastfetch";

    };
  };

}
