{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.aws;
  enable = cfg.enable;
in {
  options.modules.term.aws.enable =
    lib.mkEnableOption "aws";

  config = lib.mkIf enable {

    home.packages = with pkgs; [
      awscli2
    ];

  };
}
