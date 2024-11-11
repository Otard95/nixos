{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.bash;
  enable = cfg.enable;
in {

  options.modules.term.bash.enable = lib.mkEnableOption "bash configuration";

  config = lib.mkIf enable {
    programs.bash = {
      enable = true;

      shellAliases = {
        ll = "ls -lah";
        ".." = "cd ..";
      };

      historyControl = [
        "erasedups"
        "ignoredups"
      ];
    };
  };

}
