{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.gh-dash;
  enable = cfg.enable;
in {
  options.modules.term.gh-dash.enable =
    lib.mkEnableOption "gh-dash";

  config = lib.mkIf enable {

    modules.term.gh.enable = lib.mkDefault true;

    home.packages = [ pkgs.gh-enhance ];

    programs.gh-dash = {
      enable = true;

      settings = {
        keybindings = {
          prs = [
            {
              key = "e";
              name = "Edit PR";
              command = "gh pr edit --repo {{.RepoName}} {{.PrNumber}}";
            }
            {
              key = "T";
              name = "View PR actions";
              command = "gh-enhance -R {{.RepoName}} {{.PrNumber}}";
            }
          ] ++ lib.lists.optional config.modules.term.tuicr.enable {
              key = "D";
              name = "Review PR";
              command = "tuicr pr {{.RepoName}}#{{.PrNumber}}";
            };
        };
      };
    };

    modules.term.bash.bindToSecret.gh-dash.GITHUB_TOKEN = "github/token/cli";
    modules.term.bash.bindToSecret.gh-enhance.GITHUB_TOKEN = "github/token/cli";

  };
}
