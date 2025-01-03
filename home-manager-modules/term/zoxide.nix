{ config, lib, ... }:
let
  cfg = config.modules.term.zoxide;
  enable = cfg.enable;
in {
  options.modules.term.zoxide.enable =
    lib.mkEnableOption "zoxide";

  config = lib.mkIf enable {
    programs.zoxide = {
      enable = true;
    };
  };
}
