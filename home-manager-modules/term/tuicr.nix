{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.tuicr;
  enable = cfg.enable;

  tomlFormat = pkgs.formats.toml { };
in {
  options.modules.term.tuicr.enable =
    lib.mkEnableOption "tuicr";

  config = lib.mkIf enable {

    home.packages = [ pkgs.tuicr ];
 
    xdg.configFile."tuicr/config.toml".source = tomlFormat.generate "tuicr-config.toml" {
      theme = "catppuccin-frappe";
      comment_vim = true;
    };

    modules.term.bash.bindToSecret.tuicr.GITHUB_TOKEN = "github/token/cli";

  };
}
