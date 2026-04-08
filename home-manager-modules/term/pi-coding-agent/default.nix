{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.pi-coding-agent;
  enable = cfg.enable;
in {

  options.modules.term.pi-coding-agent.enable = lib.mkEnableOption "pi-coding-agent configuration";

  config = lib.mkIf enable {

    home.packages = [ pkgs.pi-coding-agent ];

  };

}
