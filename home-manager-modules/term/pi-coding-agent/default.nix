{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.pi-coding-agent;
  enable = cfg.enable;

  jsonFormat = pkgs.formats.json { };

  mkPiPackage = attrs: pkgs.buildNpmPackage ({
    npmPackFlags = [ "--ignore-scripts" ];
    npmInstallFlags = [ "--ignore-scripts" "--omit=dev" "--omit=peer" "--omit=optional" ];
    buildPhase = ''
      runHook preBuild
      mkdir -p $out/lib/
      runHook postBuild
    '';
    installPhase = ''
      runHook preBuild
      cp -r node_modules $out/lib/
      cp -r extensions $out/lib/
      cp -r utils $out/lib/
      cp package.json $out/lib/
      runHook postBuild
    '';
    meta.description = "A pi-coding-agent package";
  } // attrs);

  pi-extensions = mkPiPackage rec {
    pname = "pi-extensions";
    version = "0.16.0";
    src = pkgs.fetchFromGitHub {
      owner = "Otard95";
      repo = "pi-extensions";
      tag = "v${version}";
      hash = "sha256-XxDPV0P2AbKiOVOaf6JhPiGjva4QQwx4DuREANnjqJc=";
    };
    npmDepsHash = "sha256-UKeod/4JkOT/W5lXlQ8WdcatMyL/epCqyrUOdsyyi4w=";
  };
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
              "extensions/searxng/*"
              "extensions/web-read/*"
              "extensions/semantic-compaction/*"
              "extensions/session-namer/*"
              "extensions/voice-input/*"
            ];
          }
        ];
        searxng = {
          url = "https://searxng.core-lab.net";
          authorization = "pass:searxng/auth";
        };
        protected-files = {
          patterns = [
            "*.env*"
            ".secret*"
            "secrets/**"
            "*.pem"
            "*.key"
            "FrameWork/settings.json"
            "FrameWork/settings.*.json"
            "services.json"
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

