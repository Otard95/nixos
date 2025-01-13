{ config, lib, theme, ... }:
let
  cfg = config.modules.term.kitty;
  enable = cfg.enable;
in {

  options.modules.term.kitty.enable = lib.mkEnableOption "kitty configuration";

  config = lib.mkIf enable {

    programs.kitty = {
      enable = true;

      font.name = theme.font.mono;
      themeFile = "Catppuccin-Frappe";

      settings = {
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        background_opacity = "0.5";
        background_blur = 5;
        copy_on_select = "clipboard";
        window_margin_width = 5;
      };

      keybindings = {
        # kitty shell
        "kitty_mod+escape" = "no_op";
        # new_os_window
        "kitty_mod+n" = "no_op";
        # close_window
        "kitty_mod+w" = "no_op";
        # next_window
        "kitty_mod+]" = "no_op";
        # previous_window
        "kitty_mod+[" = "no_op";
        # move_window_forward
        "kitty_mod+f" = "no_op";
        # move_window_backward
        "kitty_mod+b" = "no_op";
        # move_window_to_top
        "kitty_mod+`" = "no_op";
        # start_resizing_window
        "kitty_mod+r" = "no_op";
        # first_window
        "kitty_mod+1" = "no_op";
        # second_window
        "kitty_mod+2" = "no_op";
        # third_window
        "kitty_mod+3" = "no_op";
        # fourth_window
        "kitty_mod+4" = "no_op";
        # fifth_window
        "kitty_mod+5" = "no_op";
        # sixth_window
        "kitty_mod+6" = "no_op";
        # seventh_window
        "kitty_mod+7" = "no_op";
        # eighth_window
        "kitty_mod+8" = "no_op";
        # ninth_window
        "kitty_mod+9" = "no_op";
        # tenth_window
        "kitty_mod+0" = "no_op";

        # default: kitten hints --type path --program -
        "kitty_mod+p>f" = "no_op";
        # default: kitten hints --type path
        "kitty_mod+p>shift+f" = "no_op";
        # default: kitten hints --type line --program -
        "kitty_mod+p>l" = "no_op";
        # default: kitten hints --type word --program -
        "kitty_mod+p>w" = "no_op";
        # default: kitten hints --type hash --program -
        "kitty_mod+p>h" = "no_op";
        # default: kitten hints --type linenum
        "kitty_mod+p>n" = "no_op";
        # default: kitten hints --type hyperlink
        "kitty_mod+p>y" = "no_op";
      };
    };

  };

}
