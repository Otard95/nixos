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
    version = "0.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "Otard95";
      repo = "pi-extensions";
      tag = "v${version}";
      hash = "sha256-pJ+s48/OLJ4AJUh/qw3tyI/8OkzrruXGlzpY2kF1xUk=";
    };
    npmDepsHash = "sha256-XQcBIUupEhgKt0tl2MqaHiWyaC0+Y92m2Wknitf+rK4=";
  };
in {

  options.modules.term.pi-coding-agent.enable = lib.mkEnableOption "pi-coding-agent configuration";

  config = lib.mkIf enable {

    home.packages = [ pkgs.pi-coding-agent ];

    home.sessionVariables.PI_CODING_AGENT_DIR = "\${XDG_CONFIG_HOME:-$HOME}/.config/pi";

    xdg.configFile = {
      "pi/settings.json".source = jsonFormat.generate "pi-settings.json" {
        theme = "catppuccin-frappe";
        "lastChangelogVersion" = "0.64.0";
        "defaultProvider" = "anthropic";
        "defaultModel" = "claude-sonnet-4-5";
        "defaultThinkingLevel" = "medium";
        packages = [
          "${pi-extensions}/lib"
        ];
        searxng = {
          "url" = "https://searxng.core-lab.net";
          "authorization" = "pass:searxng/auth";
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

