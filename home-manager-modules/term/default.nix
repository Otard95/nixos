{ config, lib, ... }:
let
  cfg = config.modules.term;
  enable = cfg.enable;
in {

  options.modules.term.enable = lib.mkEnableOption "terminal configuration";

  imports = [
    ./aws.nix
    ./bash.nix
    ./btop.nix
    ./direnv.nix
    ./fastfetch.nix
    ./fzf.nix
    ./git.nix
    ./k9s.nix
    ./kitty.nix
    ./starship.nix
    ./tmux.nix
    ./useful-commands.nix
    ./zoxide.nix
  ];

  config = lib.mkIf enable {
    modules.term = {
      bash.enable = lib.mkDefault true;
      btop.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      useful-commands.enable = lib.mkDefault true;
    };
  };

}
