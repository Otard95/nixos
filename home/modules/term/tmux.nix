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

    programs.tmux = {
      enable = true;

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
