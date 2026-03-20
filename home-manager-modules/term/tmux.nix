{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.tmux;
  enable = cfg.enable;
in {

  options.modules.term.tmux.enable = lib.mkEnableOption "tmux configuration";

  config = lib.mkIf enable {

    modules.term.zoxide.enable = lib.mkDefault true;

    # home.file.".local/bin/t".source =
    #   "${pkgs.tmuxPlugins.t-smart-tmux-session-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin/t";

    programs.bash = {
      shellAliases = {
        t = "~/.local/bin/t";
      };
      bashrcExtra = ''
        tx() { tmux new-session -s $1 $1; }
        export -f tx
        tmux() {
          if [ "$#" -eq 0 ]; then
            command tmux new-session -A -s default
          else
            command tmux "$@"
          fi
        }
        export -f tmux
      '';
    };

    catppuccin.tmux = {
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

          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_status_right_separator ""
          set -g status-right ""
          set -ag status-right "#{E:@catppuccin_status_session}"
      '';
    };

    programs.tmux = {
      enable = true;

      aggressiveResize = true;
      baseIndex = 1;
      disableConfirmationPrompt = true;
      keyMode = "vi";
      secureSocket = true;
      shortcut = "a";
      terminal = "tmux-256color";
      mouse = true;

      plugins = with pkgs.tmuxPlugins; [
        yank
        sensible
        vim-tmux-navigator
        # t-smart-tmux-session-manager
        tmux-sessionx
      ];

      extraConfig = ''
        set-option -g detach-on-destroy off
        set -g status-position top
        set -g allow-passthrough on

        #################
        #  keybindings  #
        #################

        set -g extended-keys on
        set -g extended-keys-format csi-u

        # Sessions

        bind l switch-client -l
        bind r command-prompt -I "#{session_name}" "rename-session -- '%%'"

        bind X command-prompt -p "Command:" "new-session -s '%1' '%1'"

        # Tabs/Windows

        bind -n C-S-t new-window
        bind -n C-S-w kill-window

        bind -n C-S-1 select-window -t 1
        bind -n C-S-2 select-window -t 2
        bind -n C-S-3 select-window -t 3
        bind -n C-S-4 select-window -t 4
        bind -n C-S-5 select-window -t 5
        bind -n C-S-6 select-window -t 6
        bind -n C-S-7 select-window -t 7
        bind -n C-S-8 select-window -t 8
        bind -n C-S-9 select-window -t 9

        bind < swap-window -t :-1 \; select-window -t :-1
        bind > swap-window -t :+1 \; select-window -t :+1

        # Panes/Splits

        unbind %
        bind | split-window -h

        unbind '"'
        bind - split-window -v

        bind 0 next-layout

        bind -n C-S-h resize-pane -L 5
        bind -n C-S-j resize-pane -D 5
        bind -n C-S-k resize-pane -U 5
        bind -n C-S-l resize-pane -R 5

        # Toggle maximized pane
        bind -r m resize-pane -Z

        # Copy mode with vim bindings

        bind -n C-S-x copy-mode
        bind-key -T copy-mode-vi Escape if-shell -F '#{selection_present}' {
          send -X clear-selection
        } {
          send -X cancel
        }
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi V send -X select-line
        bind-key -T copy-mode-vi C-v if-shell -F '#{selection_present}' {
          send -X rectangle-toggle
        } {
          send -X begin-selection
          send -X rectangle-on
        }
        bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

        unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse

        # Use C-l to clear the screen since we use 'christoomey/vim-tmux-navigator'
        bind C-l send-keys C-l

      '';
    };
    xdg.configFile."tmux/tmux.conf".text = lib.mkOrder 600 ''
        ####################
        #  plugin settings #
        ####################

        set -g @sessionx-bind 'j'
        set -g @sessionx-zoxide-mode 'on'
        # set -g @t-fzf-prompt '  '
        # set -g @t-bind "j"
    '';

  };

}
