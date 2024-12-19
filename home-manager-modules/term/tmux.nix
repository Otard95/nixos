{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.tmux;
  enable = cfg.enable;
in {

  options.modules.term.tmux.enable = lib.mkEnableOption "tmux configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      tmux
    ];

    home.file.".local/bin/t".source =
      "${pkgs.tmuxPlugins.t-smart-tmux-session-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin/t";
    programs.bash.shellAliases = {
      t = "~/.local/bin/t";
    };

    programs.tmux = { # TODO: port rest of old config, bar settings, etc.
      enable = true;

      catppuccin = {
        enable = true;
        flavor = "frappe";
        extraConfig = ''
          set -g @catppuccin_window_status_style "rounded"
          # set -g @catppuccin_window_status_style "custom"
          # set -g @catppuccin_window_left_separator ""
          # set -g @catppuccin_window_right_separator " "
          # set -g @catppuccin_window_middle_separator " "
          set -g @catppuccin_status_background "#{@thm_bg}"
          set -g @catppuccin_window_current_number_color "#{@thm_teal}"

          set -g status-left ""
          set -g status-left-length 100

          set -g status-right ""
          set -ag status-right "#{E:@catppuccin_status_session}"
        '';
      };

      aggressiveResize = true;
      baseIndex = 1;
      disableConfirmationPrompt = true;
      keyMode = "vi";
      newSession = true;
      secureSocket = true;
      shortcut = "a";
      terminal = "screen-256color";
      mouse = true;

      plugins = with pkgs.tmuxPlugins; [
        yank
        sensible
        vim-tmux-navigator
        t-smart-tmux-session-manager
      ];

      extraConfig = ''
        set -g status-position top

        # keybindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        unbind %
        bind | split-window -h

        unbind '"'
        bind - split-window -v

        bind 0 next-layout

        bind C-l send-keys C-l
      '';
    };
    xdg.configFile."tmux/tmux.conf".text = lib.mkOrder 600 ''
        set -g @t-fzf-prompt '  '
        set -g @t-bind "j"
    '';
  };

}
