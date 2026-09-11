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
        collapseChangelog = false;
        lastChangelogVersion = "0.84.1";
        defaultProvider = "anthropic";
        defaultModel = "claude-sonnet-4-6";
        defaultThinkingLevel = "medium";
        enableInstallTelemetry = false;
        packages = [
          {
            source = "${pi-extensions}/lib";
            extensions = [
              "extensions/context-inspector/*"
              "extensions/continue/*"
              "extensions/guards/*"
              "extensions/load-skill/*"
              "extensions/pi-cloak/*"
              "extensions/protected-files/*"
              "extensions/read-line-numbers/*"
              "extensions/save-md/*"
              "extensions/screenshot/*"
              "extensions/web-search/*"
              "extensions/web-read/*"
              "extensions/semantic-compaction/*"
              "extensions/session-namer/*"
              "extensions/voice-input/*"
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
              window = { s = 5; };
              message = "Over use causes upstream rate-limits. Investigate searches before doing another";
            };
            prefer-traverse = {
              count = 5;
              window = { s = 30; };
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
      };
      "pi/agents" = { source = ./agents; recursive = true; };
      "pi/modes" = { source = ./modes; recursive = true; };
      "pi/prompts" = { source = ./prompts; recursive = true; };
    };

  };

}

