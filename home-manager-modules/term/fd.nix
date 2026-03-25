{ config, lib, ... }:
let
  cfg = config.modules.term.fd;
  enable = cfg.enable;
in {

  options.modules.term.fd.enable = lib.mkEnableOption "fd configuration";

  config = lib.mkIf enable {
    programs.fd.enable = true;
  };

}
