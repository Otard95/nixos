{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.claude;
  enable = cfg.enable;

  useScript = file: pkgs.writeShellScriptBin (builtins.baseNameOf file) (builtins.readFile file);
in {

  options.modules.term.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf enable {

    programs.claude-code = {
      enable = true;

      settings = {
        includeCoAuthoredBy = false;
        permissions = {
          # additionalDirectories = [
          #   "../docs/"
          # ];
          allow = [
            "Bash(git diff:*)"
            "Bash(mkdir:*)"
            "Bash(grep:*)"
            "Bash(awk:*)"
            "Bash(jq:*)"
            "Bash(pnpm run build)"
            "Bash(pnpm run lint)"
            "Bash(pnpm run lint:fix)"
            "Bash(pnpm --filter:*)"
            "Bash(pnpm --filter:*)"
            "Bash(pnpm --filter:*)"
            "mcp__obsidian__obsidian_list_files_in_dir"
            "mcp__obsidian__obsidian_list_files_in_vault"
            "mcp__obsidian__obsidian_get_file_contents"
            "mcp__obsidian__obsidian_simple_search"
            "mcp__obsidian__obsidian_delete_file"
            "mcp__obsidian__obsidian_complex_search"
            "mcp__obsidian__obsidian_batch_get_file_contents"
            "mcp__obsidian__obsidian_get_periodic_note"
            "mcp__obsidian__obsidian_get_recent_periodic_notes"
            "mcp__obsidian__obsidian_get_recent_changes"
            "mcp__clickup__get_task"
            "mcp__clickup__search_tasks"
            "mcp__clickup__search_spaces"
            "mcp__clickup__get_space_structure"
            "mcp__clickup__get_tasks_in_list"
            "mcp__clickup__get_list_info"
            "mcp__clickup__get_task_comments"
            "mcp__clickup__get_time_entries"
            "mcp__clickup__read_document"
            "mcp__clickup__search_documents"
            "mcp__clickup__get_task_relationships"
            "mcp__memory"
          ];
          # ask = [
          #   "Bash(git push:*)"
          # ];
          # defaultMode = "acceptEdits";
          deny = [
            "Read(./.env)"
            "Read(./.env*)"
            "Read(./**/.env)"
            "Read(./**/.env*)"
            "Read(./secrets/**)"
            "Read(./**/secrets/**)"
            "Read(./services.json)"
            "Read(./**/services.json)"
            "Read(./settings.json)"
            "Read(./**/settings.json)"
          ];
          disableBypassPermissionsMode = "disable";
        };
        hooks = {
          SessionStart = [
            {
              hooks = [
                {
                  type = "command";
                  command = ''
                    echo '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"**TODAYS DATE**: '"$(date)"'"}}'
                  '';
                }
              ];
            }
          ];
          Notification = [
            {
              hooks = [
                {
                  type = "command";
                  command = ''
                    jq '.message' | xargs notify-send -t 6000 "✨ Claude"
                  '';
                }
              ];
            }
          ];
          Stop = [
            {
              hooks = [
                {
                  type = "command";
                  command = ''
                    jq '.transcript_path' | xargs jq 'select(.type == "summary") // { "summary": "Waiting for input" } | .summary' | tail -n 1 | xargs notify-send -t 6000 "✨ Claude"
                  '';
                }
              ];
            }
          ];
          PostToolUse = [
            {
              matcher = "Read";
              hooks = [
                {
                  type = "command";
                  command = "${lib.getExe (useScript ./hooks/rule-and-docs-reminder.sh)}";
                }
              ];
            }
            {
              matcher = "Write|Edit";
              hooks = [
                {
                  type = "command";
                  command = "${lib.getExe (useScript ./hooks/validate-reminder.sh)}";
                }
              ];
            }
          ];
        };
        theme = "dark";
      };

      commands = let
        fileNames = builtins.attrNames (builtins.readDir ./commands);
        files = map (name: {
          name = "${lib.strings.removeSuffix ".md" name}";
          value = builtins.readFile (lib.path.append ./commands "${name}");
        }) fileNames;
      in builtins.listToAttrs files;

      agents = let
        fileNames = builtins.attrNames (builtins.readDir ./agents);
        files = map (name: {
          name = "${lib.strings.removeSuffix ".md" name}";
          value = builtins.readFile (lib.path.append ./agents "${name}");
        }) fileNames;
      in builtins.listToAttrs files;

      mcpServers = {
        # github = {
        #   type = "http";
        #   url = "https://api.githubcopilot.com/mcp/";
        #   headers = {
        #     Authorization = "Bearer \${GITHUB_TOKEN_CLAUDE}";
        #   };
        # };
        memory = {
          command = "docker";
          args = [
            "run" "-i" "--rm"
            "-v" "/home/otard/.claude/memory-mcp:/home/mcpuser/.claude/memory-mcp"
            "-e" "PWD"
            "memory-mcp-server"
          ];
        };
        clickup = {
          command = "pass-env";
          args = [
            "CLICKUP_API_TOKEN=keys/clickup"
            "docker" "run"
            "-i"
            "--rm"
            "-e" "CLICKUP_API_TOKEN"
            "-e" "CLICKUP_TEAM_ID"
            "clickup-mcp-server"
          ];
          env = {
            "CLICKUP_TEAM_ID" = "2628532";
          };
        };
        obsidian = {
          command = "pass-env";
          args = [
            "OBSIDIAN_API_KEY=keys/obsidian"
            "${pkgs.uv}/bin/uvx"
            "mcp-obsidian"
          ];
        };
      };

    };

    modules.term.bash.bindToSecret.claude = {
      # GITHUB_TOKEN_CLAUDE = "github/token/claude";
      GITHUB_TOKEN = "github/token/packages";
      TURBOREPO_TOKEN = "keys/turbo";
    };

  };

}
