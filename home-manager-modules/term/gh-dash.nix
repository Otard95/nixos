{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.gh-dash;
  enable = cfg.enable;

  gh-mark-merged-done = pkgs.writeShellScriptBin "gh-mark-merged-done" ''
    set -euo pipefail

    DONE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/gh-dash/done.json"

    gh api "notifications?all=true" --paginate \
      --jq '.[] | select(.subject.type == "PullRequest") | "\(.id)\t\(.subject.url)\t\(.updated_at)"' |
    while IFS=$'\t' read -r thread_id pr_url updated_at; do
      if [[ -f "$DONE_FILE" ]]; then
        done_at=$(jq -r --arg id "$thread_id" '.[$id] // empty' "$DONE_FILE")
        if [[ -n "$done_at" && ! "$updated_at" > "$done_at" ]]; then
          continue
        fi
      fi

      merged=$(gh api "$pr_url" --jq '.merged')
      if [[ "$merged" == "true" ]]; then
        gh api -X DELETE "notifications/threads/$thread_id" --silent
        tmp=$(mktemp)
        jq --arg id "$thread_id" --arg ts "$updated_at" '. + {($id): $ts}' "$DONE_FILE" > "$tmp" \
          && mv "$tmp" "$DONE_FILE"
        echo "Marked done: $thread_id"
      fi
    done
  '';
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
              key = "ctrl+r";
              name = "Review PR";
              command = "tuicr pr {{.RepoName}}#{{.PrNumber}}";
            };
          notifications = [
            {
              key = "ctrl+d";
              name = "Mark merged as done";
              command = lib.getExe gh-mark-merged-done;
            }
          ];
        };
      };
    };

    modules.term.bash.bindToSecret.gh-dash.GITHUB_TOKEN = "github/token/cli";
    modules.term.bash.bindToSecret.gh-enhance.GITHUB_TOKEN = "github/token/cli";

  };
}
