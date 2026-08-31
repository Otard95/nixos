{ config, lib, ... }:
let
  cfg = config.modules.term.gh-dash;
  enable = cfg.enable;
in {
  options.modules.term.gh-dash.enable =
    lib.mkEnableOption "gh-dash";

  config = lib.mkIf enable {

    programs.gh-dash = {
      enable = true;

      settings = {
        keybindings = {
          prs = [
            {
              key = "e";
              name = "edit";
              command = "gh pr edit --repo {{.RepoName}} {{.PrNumber}}";
            }
          ];
        };
      };
    };

    modules.term.bash.bindToSecret.gh-dash.GITHUB_TOKEN = "github/token/cli";

  };
}
