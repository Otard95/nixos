{ config, lib, ... }:
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
        vi = "nvim";
      };

      historyControl = [
        "ignoreboth"
      ];

      bashrcExtra = ''
        # Secrets
        if [ -d ~/.secret ]; then
          for file in $(ls -a ~/.secret); do
            if [[ -f ~/.secret/$file ]] && [[ -n "''${file##*ignore*}" ]]; then
              source ~/.secret/$file
            fi
          done
        fi
      '';
    };
  };

}
