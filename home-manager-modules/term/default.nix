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
      type = lib.types.enum [ "kitty" "wezterm" ];
      default = "wezterm";
    };
  };

  imports = [
    ./claude
    ./scripts
    ./wezterm
    ./aws.nix
    ./bash.nix
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./fastfetch.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./k9s.nix
    ./kitty.nix
    ./pass.nix
    ./ssh.nix
    ./starship.nix
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
      git.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault (cfg.defaultTerminal == "kitty");
      ssh.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      useful-commands.enable = lib.mkDefault true;
      wezterm.enable = lib.mkDefault (cfg.defaultTerminal == "wezterm");
    };
  };

}
