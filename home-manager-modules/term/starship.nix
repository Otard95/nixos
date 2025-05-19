{ config, lib, ... }:
let
  cfg = config.modules.term.starship;
  enable = cfg.enable;
in {

  options.modules.term.starship.enable = lib.mkEnableOption "starship configuration";

  config = lib.mkIf enable {
    catppuccin.starship.enable = true;

    programs.starship = {
      enable = true;

      settings = {
        format = lib.concatStrings [
        "[](surface0)"
        "[    ](bg:surface0 fg:text)"
        "[](bg:teal fg:surface0)"
        "$directory"
        "[](fg:teal bg:surface1)"
        "$git_branch"
        "$git_status"
        "[](fg:surface1)"
        "$fill"
        "$status"
        "[](fg:surface1)"
        "$nodejs"
        "$rust"
        "$php"
        "[](fg:surface0 bg:surface1)"
        "$time"
        "[](fg:surface0)\n"
        " $character"
        ];

        directory = {
          style = "fg:crust bg:teal";
          format = "[ $path ]($style)";
          truncation_length = 6;
          truncation_symbol = "/";
          substitutions = {
            Documents = "󱔘 ";
            Downloads = " ";
            Music = " ";
            Pictures = " ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:surface1";
          format = "[[ $symbol $branch ](fg:teal bg:surface1)]($style)";
        };

        git_status = {
          style = "bg:surface1";
          format = "[[($all_status$ahead_behind )](fg:teal bg:surface1)]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:surface1";
          format = "[[ $symbol ($version) ](fg:teal bg:surface1)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:surface1";
          format = "[[ $symbol ($version) ](fg:teal bg:surface1)]($style)";
        };

        php = {
          symbol = "";
          style = "bg:surface1";
          format = "[[ $symbol ($version) ](fg:teal bg:surface1)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R"; # Hour:Minute Format
          style = "bg:surface0";
          format = "[[  $time ](fg:text bg:surface0)]($style)";
        };

        cmd_duration = {
          disabled = true;
          min_time = 500;
          format = "[ $duration ](fg:text)";
          show_milliseconds = true;
        };

        status = {
          format = "[$symbol $status](fg:text) ";
          symbol = "🔴";
          map_symbol = true;
          disabled = false;
        };
      };
    };
  };

}
