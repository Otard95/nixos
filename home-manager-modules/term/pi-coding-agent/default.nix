{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.term.pi-coding-agent;
  enable = cfg.enable;

  jsonFormat = pkgs.formats.json { };

  pi-extensions = inputs.pi-extensions.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {

  options.modules.term.pi-coding-agent.enable = lib.mkEnableOption "pi-coding-agent configuration";

  config = lib.mkIf enable {

    home.packages = with pkgs; [
      pi-coding-agent
      ffmpeg
      whisper-cpp
    ];

    home.sessionVariables.PI_CODING_AGENT_DIR = "\${XDG_CONFIG_HOME:-$HOME}/.config/pi";

    xdg.configFile = {
      "pi/settings.json".source = jsonFormat.generate "pi-settings.json" {
        theme = "catppuccin-frappe";
        collapseChangelog = true;
        defaultProvider = "openai-codex";
        defaultModel = "gpt-6.1-sol";
        defaultThinkingLevel = "medium";
        enableInstallTelemetry = false;
        defaultTools = [ "+codemode" ];
        packages = [
          {
            source = "${pi-extensions}/lib";
            extensions = [
              "extensions/context-inspector/*"
              "extensions/continue/*"
              "extensions/guards/*"
              "extensions/load-skill/*"
              "extensions/modes/*"
              "extensions/pi-cloak/*"
              "extensions/protected-files/*"
              "extensions/read-line-numbers/*"
              "extensions/save-md/*"
              "extensions/screenshot/*"
              "extensions/self-improvement/*"
              "extensions/web-search/*"
              "extensions/web-read/*"
              "extensions/semantic-compaction/*"
              "extensions/session-namer/*"
            ];
          }
        ];
        protected-files = {
          patterns = [
            ".secret*"
            "secrets/**"
            "*.pem"
            "*.key"
          ];
        };
        guards.typesafe.token = "pass:typesafe/api-key";
        pass = {
          timeout = 30000;
        };
        screenshot = {
          exclude = [
            { title = "Proton Pass"; }
            { class = "yubioath"; }
            { class = "1password"; }
          ];
        };
        web-search = {
          providers = ["duckduckgo" "brave"];
          rate-limit = let
            no-burst = {
              count = 2;
              window = { s = 10; };
              message = "Over use causes upstream rate-limits. Investigate searches before doing another";
            };
            prefer-traverse = {
              count = 5;
              window = { s = 60; };
              message = "Prefer traversing links found on the sites you already know";
            };
          in {
            duckduckgo = [ no-burst prefer-traverse ];
            brave = [ no-burst prefer-traverse ];
          };
        };
        web-read = {
          browserPath = lib.getExe pkgs.chromium;
        };
      };
      "pi/keybindings.json".source = jsonFormat.generate "pi-keybindings.json" {
        "tui.input.submit" =  "ctrl+enter";
        "tui.input.newLine" = "enter";
        "tui.editor.undo" = "alt+u";
        "tui.altScreen.halfPageUp" = "alt+u";
        "tui.altScreen.halfPageDown" = "alt+d";
        "tui.altScreen.lineUp" = "alt+k";
        "tui.altScreen.lineDown" = "alt+j";
      };
      "pi/mcp.json".source = jsonFormat.generate "pi-mcp.json" {
        mcpServers = {
          github = {
            url = "https://api.githubcopilot.com/mcp/";
            headers = {
              Authorization = "!echo Bearer $(pass show github/token/cli)";
              "X-MCP-Toolsets" = "context,repos,issues,pull_requests,users,actions,labels,notifications,copilot,orgs";
            };
            description = "GitHub repositories, issues, pull requests, Actions, labels, notifications, Copilot, and organizations";
          };
          clickup = {
            url = "https://mcp.clickup.com/mcp";
            description = "ClickUp tasks, docs, comments, time tracking";
          };
          graphos = {
            url = "https://mcp.apollographql.com";
            headers."x-api-key" = "!pass show apollo/token/user";
            description = "Apollo GraphOS Studio: graphs, variants, operation and subgraph metrics, docs";
          };
        };
      };
      "pi/agents" = { source = ./agents; recursive = true; };
      "pi/modes" = { source = ./modes; recursive = true; };
      "pi/prompts" = { source = ./prompts; recursive = true; };
    };

  };

}

