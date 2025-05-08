{ config, lib, ... }:
let
  cfg = config.modules.term;
  enable = cfg.enable;
in {

  options.modules.term.enable = lib.mkEnableOption "terminal configuration";

  imports = [
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
    ./ssh.nix
    ./starship.nix
    ./thefuck.nix
    ./tmux.nix
    ./useful-commands.nix
    ./wezterm.nix
    ./zoxide.nix
  ];

  config = lib.mkIf enable {
    modules.term = {
      bash.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      btop.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      useful-commands.enable = lib.mkDefault true;
      wezterm.enable = lib.mkDefault true;
    };
  };

}
