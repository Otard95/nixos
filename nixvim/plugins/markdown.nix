{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.markdown;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.markdown.enable =
    lib.mkEnableOption "markdown plugins";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPlugins = [
        pkgs.vimPlugins.vim-markdown-toc
      ];

      plugins.render-markdown = {
        enable = true;

        settings = {
          completions = { lsp = { enabled = true; }; };
          bullet = { left_pad = 1; };
          checkbox = {
            unchecked = {
              icon = " 󰄱";
            };
            checked = {
              icon = " 󰱒";
            };
            custom = {
              todo = { raw = "[-]"; rendered = " 󰥔"; highlight = "RenderMarkdownTodo"; };
              follow_up = { raw = "[>]"; rendered = " 󰬪"; highlight = "WarningMsg"; };
              canceled = { raw = "[~]"; rendered = " 󰅙"; highlight = "ErrorMsg"; };
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
            # Determines how the top / bottom of code block are rendered.
            # | none  | do not render a border                               |
            # | thick | use the same highlight as the code body              |
            # | thin  | when lines are empty overlay the above & below icons |
            # | hide  | conceal lines unless language name or icon is added  |
            border = "thin";
            # Used below code blocks for thin border.
            below = "▀";
          };

          overrides = {
            buftype = {
              nofile = {
                code = { left_pad = 0; right_pad = 0; below = null; };
                padding = { highlight = "NormalFloat"; };
                sign = { enabled = false; };
              };
            };
          };
        };
      };
    };
  };
}
