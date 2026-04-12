{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.pi-coding-agent;
  enable = cfg.enable;

  jsonFormat = pkgs.formats.json { };
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

