{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.term.aven;
  enable = cfg.enable;

  yamlFormat = pkgs.formats.yaml { };
in {
  options.modules.term.aven.enable =
    lib.mkEnableOption "aven";

  config = lib.mkIf enable {

    home.packages = [ inputs.aven.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    xdg.configFile = {
      "workmux/config.yaml".source = yamlFormat.generate "workmux-config.yaml" {
        mode = "session";
        agent = "pi";
        merge_strategy = "squash";
        windows = [
          {
            name = "editor";
            panes = [ { command = "nvim"; focus = true; } ];
          }
          {
            name = "agent";
            panes = [ { command = "<agent>"; } ]; }
          {
            name = "shell";
            panes = [ { command = "if test -f .workmux-shell.sh; then sh .workmux-shell.sh; fi"; } ];
          }
        ];
      };
    };
  };
}
