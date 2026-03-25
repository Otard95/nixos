{ config, lib, ... }:
let
  cfg = config.modules.term;
  enable = cfg.enable;
in {

  options.modules.term = {
    enable = lib.mkEnableOption "terminal configuration";

    defaultTerminal = lib.mkOption {
      description = ''
        Set the your default terminal.
        This determines which terminal your window manager will start,
        which tmux and nvim integrations are enabled by default, etc.
      '';
      type = lib.types.enum [ "kitty" "wezterm" "ghostty" ];
      default = "wezterm";
    };
  };

  imports = [
    ./claude
    ./opencode
    ./scripts
    ./wezterm
    ./aws.nix
    ./bash.nix
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./fastfetch.nix
    ./fd.nix
    ./fzf.nix
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./k9s.nix
    ./kitty.nix
    ./pass.nix
    ./ssh.nix
    ./starship.nix
    ./television.nix
    ./tmux.nix
    ./useful-commands.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  config = lib.mkIf enable {
    modules.term = {
      bash.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      btop.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault (cfg.defaultTerminal == "ghostty");
      git.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault (cfg.defaultTerminal == "kitty");
      ssh.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      television.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault (cfg.defaultTerminal != "wezterm");
      useful-commands.enable = lib.mkDefault true;
      wezterm.enable = lib.mkDefault (cfg.defaultTerminal == "wezterm");
    };
  };

}
