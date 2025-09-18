{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.gh;
  enable = cfg.enable;
in {
  options.modules.term.gh.enable =
    lib.mkEnableOption "gh";

  config = lib.mkIf enable {

    home.packages = with pkgs; [ delta ];

    programs.gh = {
      enable = true;

      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        pager = "${pkgs.delta}/bin/delta";
      };
    };

    modules.term.bash.bindToSecret.gh.GITHUB_TOKEN = "github/token/cli";

  };
}
