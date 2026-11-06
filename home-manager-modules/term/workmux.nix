{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.term.workmux;
  enable = cfg.enable;

  yamlFormat = pkgs.formats.yaml { };
in {
  options.modules.term.workmux.enable =
    lib.mkEnableOption "workmux";

  config = lib.mkIf enable {
    home.packages = [ inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    xdg.configFile = {
      "workmux/config.yaml".source = yamlFormat.generate "workmux-config.yaml" {
        nerdfont = true;

        mode = "session";
        agent = "pi";
        merge_strategy = "squash";
        worktree_dir = "..";
        worktree_naming = "full";

        windows = [
          { name = "editor"; }
          { name = "agent"; }
          { name = "shell"; }
        ];
      };
    };
  };
}
