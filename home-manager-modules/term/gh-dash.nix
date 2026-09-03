{ config, lib, ... }:
let
  cfg = config.modules.term.gh-dash;
  enable = cfg.enable;
in {
  options.modules.term.gh-dash.enable =
    lib.mkEnableOption "gh-dash";

  config = lib.mkIf enable {

    modules.term.gh.enable = lib.mkDefault true;

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
          ] ++ lib.lists.optional config.modules.term.tuicr.enable {
              key = "D";
              name = "review";
              command = "tuicr pr {{.RepoName}}#{{.PrNumber}}";
            };
        };
      };
    };

    modules.term.bash.bindToSecret.gh-dash.GITHUB_TOKEN = "github/token/cli";

  };
}
