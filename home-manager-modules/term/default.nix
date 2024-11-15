{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term;
  enable = cfg.enable;
in {

  options.modules.term.enable = lib.mkEnableOption "terminal configuration";

  imports = [
    ./bash.nix
    ./fzf.nix
    ./kitty.nix
    ./nixvim
    ./starship.nix
    ./tmux.nix
    ./useful-commands.nix
  ];

  config = lib.mkIf enable {
    modules.term.bash.enable = lib.mkDefault true;
    modules.term.fzf.enable = lib.mkDefault true;
    modules.term.kitty.enable = lib.mkDefault true;
    modules.term.starship.enable = lib.mkDefault true;
    modules.term.tmux.enable = lib.mkDefault true;
    modules.term.useful-commands.enable = lib.mkDefault true;
    modules.nixvim.enable = lib.mkDefault true;
  };

}
