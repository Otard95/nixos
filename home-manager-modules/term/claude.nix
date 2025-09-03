{ config, lib, ... }:
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
          # allow = [
          #   "Bash(git diff:*)"
          #   "Edit"
          # ];
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

          Based on the changes above, create a single atomic git commit with a descriptive message.
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
        github = {
          type = "http";
          url = "https://api.githubcopilot.com/mcp/";
          headers = {
            Authorization = "Bearer \${GITHUB_TOKEN_CLAUDE}";
          };
        };
      };

    };

  };

}
