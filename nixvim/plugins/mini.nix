{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.mini;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;

  mkModuleOption = name: defaultSettings: {
    enable = lib.mkEnableOption name;
    settings = lib.mkOption {
      description = "${name} module settings";
      default = defaultSettings;
      type = with lib.types; attrsOf anything;
    };
  };
in {
  options.modules.nixvim.plugins.mini = {
    enable = lib.mkEnableOption "mini plugins";

    modules = {
      icons = mkModuleOption "icons" { enable = true; };
      indentscope = mkModuleOption "icons" {
        symbol = "⡇";
        draw = {
          animation = nixvim.mkRaw ''
            require('mini.indentscope').gen_animation.linear({ duration = 100, unit = 'total' })
          '';
        };
      };
    };
  };

  config = lib.mkIf enable {

    programs.nixvim.plugins.mini = {
      enable = true;
      mockDevIcons = cfg.modules.icons != false;
      modules = {
        icons = lib.mkIf cfg.modules.icons.enable cfg.modules.icons.settings;
        indentscope = lib.mkIf cfg.modules.indentscope.enable cfg.modules.indentscope.settings;
      };
    };

  };
}
