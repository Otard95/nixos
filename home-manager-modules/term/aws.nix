{ config, lib, pkgs-stable, ... }:
let
  cfg = config.modules.term.aws;
  enable = cfg.enable;
in {
  options.modules.term.aws.enable =
    lib.mkEnableOption "aws";

  config = lib.mkIf enable {

    home.packages = with pkgs-stable; [
      awscli2
    ];

    modules.term.bash.bindToSecret.envineer = {
      AWS_ACCESS_KEY_ID = "aws/access-key-id";
      AWS_SECRET_ACCESS_KEY = "aws/secret-access-key";
    };

  };
}
