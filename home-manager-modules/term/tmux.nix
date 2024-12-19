{ config, lib, pkgs, ... }:
let
  # catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
  #   pluginName = "catppuccin";
  #   version = "unstable-2023-01-06";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "dreamsofcode-io";
  #     repo = "catppuccin-tmux";
  #     rev = "main";
  #     sha256 = "sha256-FJHM6LJkiAwxaLd5pnAoF3a7AE1ZqHWoCpUJE0ncCA8=";
  #   };
  # };

  cfg = config.modules.term.tmux;
  enable = cfg.enable;
in {

  options.modules.term.tmux.enable = lib.mkEnableOption "tmux configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      tmux
    ];

    programs.tmux = { # TODO: port rest of old config, bar settings, etc.
      enable = true;

      catppuccin = {
        enable = true;
        flavor = "frappe";
        extraConfig = ''
          set -g status-left ""
          set -g @catppuccin_window_status_style "rounded"
          # set -g @catppuccin_window_status_style "custom"
          # set -g @catppuccin_window_left_separator "#[fg=#{@_ctp_status_bg},bg=#{@thm_bg}]#[bg=#{@_ctp_status_bg}]"
          # set -g @catppuccin_window_right_separator "#[fg=#{@_ctp_status_bg,bg=#{@thm_bg}}] #[none]"
          # set -g @catppuccin_window_middle_separator " "
          # set -g @catppuccin_status_background "#{@thm_bg}"
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
  };

}
