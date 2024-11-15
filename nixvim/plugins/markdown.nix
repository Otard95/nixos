{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.markdown;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.markdown.enable =
    lib.mkEnableOption "markdown plugins";

  config = lib.mkIf enable {
    programs.nixvim.plugins.render-markdown = {
      enable = true;

      settings = {
        checkbox = {
          unchecked = {
            icon = "󰄱";
          };
          checked = {
            icon = "󰱒";
          };
          custom = {
            todo = { raw = "[-]"; rendered = "󰥔"; highlight = "RenderMarkdownTodo"; };
            follow_up = { raw = "[>]"; rendered = "󰬪"; highlight = "WarningMsg"; };
            canceled = { raw = "[~]"; rendered = "󰅙"; highlight = "ErrorMsg"; };
          };
        };
        code = {
          # Width of the code block background:
          #  block: width of the code block
          #  full:  full width of the window
          width = "block";
          # Amount of padding to add to the left of code blocks
          left_pad = 2;
          # Amount of padding to add to the right of code blocks when width is "block"
          right_pad = 1;
          # Minimum width to use for code blocks when width is "block"
          min_width = 80;
        };
      };
    };
  };
}
