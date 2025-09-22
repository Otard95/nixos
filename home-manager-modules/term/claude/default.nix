{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.claude;
  enable = cfg.enable;
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
            "mcp__clickup__getTaskById"
            "mcp__clickup__searchTasks"
            "mcp__clickup__searchSpaces"
            "mcp__clickup__getListInfo"
            "mcp__clickup__getTimeEntries"
            "mcp__clickup__readDocument"
            "mcp__clickup__searchDocuments"
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
          ];
          disableBypassPermissionsMode = "disable";
        };
        hooks = {
          PostToolUse = [
            {
              hooks = [
                {
                  command = ''
                    echo '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Have you remembered critical things? Read the correct rules, docs, etc.? Have you tested, built, linted, etc.? Or anything else thats relevant for what you are doing?"}}'
                  '';
                  type = "command";
                }
              ];
              matcher = "Read|Write|Edit";
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

      mcpServers = {
        # github = {
        #   type = "http";
        #   url = "https://api.githubcopilot.com/mcp/";
        #   headers = {
        #     Authorization = "Bearer \${GITHUB_TOKEN_CLAUDE}";
        #   };
        # };
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
