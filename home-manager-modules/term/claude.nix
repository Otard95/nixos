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
        theme = "dark";
      };

      commands = {
        commit = ''
          ---
          allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
          description: Create a git commit with proper message
          ---
          ## Context

          - Current git status: !`git status`
          - Current git diff: !`git diff HEAD`
          - Recent commits: !`git log --oneline -5`

          ## Task

          Create one or more atomic git commits with descriptive messages. Each commit should represent a single logical change that can stand alone.

          **Critical considerations:**
          - **Analyze the actual changes** - understand what was modified and why
          - **Review project documentation** - consult CLAUDE.md, .claude/rules/, and any relevant project guidelines
          - **Group related changes** - stage and commit logically related modifications together
          - **Separate unrelated changes** - create multiple commits when changes serve different purposes
          - **Follow project conventions** - adhere to the repository's commit message format and practices

          Ensure each commit is atomic (complete, testable, and reversible) while accurately reflecting the intent and scope of the changes made.
        '';
        fix-issue = ''
          ---
          allowed-tools: Bash(git status:*), Read
          argument-hint: [issue-number]
          description: Fix GitHub issue following coding standards
          ---
          Fix issue #$ARGUMENTS following our coding standards and best practices.
        '';
      };

      mcpServers = {
        # github = {
        #   type = "http";
        #   url = "https://api.githubcopilot.com/mcp/";
        #   headers = {
        #     Authorization = "Bearer \${GITHUB_TOKEN_CLAUDE}";
        #   };
        # };
        clickup = {
          command = "${pkgs.nodejs_24}/bin/npx";
          args = [ "-y" "@hauptsache.net/clickup-mcp@latest" ];
          env = {
            "CLICKUP_API_KEY" = "\${CLICKUP_API_KEY}";
            "CLICKUP_TEAM_ID" = "2628532";
          };
        };
        obsidian = {
          command = "${pkgs.uv}/bin/uvx";
          args = [
            "mcp-obsidian"
          ];
          env = {
            OBSIDIAN_API_KEY = "\${OBSIDIAN_TOKEN}";
          };
        };
      };

    };

  };

}
