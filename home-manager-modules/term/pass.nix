{ config, lib, pkgs, theme, inputs, ... }:
let
  cfg = config.modules.term.pass;
  enable = cfg.enable;
in {
  options.modules.term.pass.enable = lib.mkEnableOption "pass";

  config = lib.mkIf enable {

    home.packages = [ inputs.pass-env.packages."${pkgs.stdenv.hostPlatform.system}".default ];

    modules.term.gpg.enable = lib.mkDefault true;

    programs = {
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "\${XDG_DATA_HOME:-$HOME/.local/share}/password-store";
          PASSWORD_STORE_KEY = "59CA827A1DE6C7CE";
        };
      };
    };

  };
}
