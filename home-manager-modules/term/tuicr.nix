{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.tuicr;
  enable = cfg.enable;
in {
  options.modules.term.tuicr.enable =
    lib.mkEnableOption "tuicr";

  config = lib.mkIf enable {

    home.packages = [ pkgs.tuicr ];

    modules.term.bash.bindToSecret.tuicr.GITHUB_TOKEN = "github/token/cli";

  };
}
