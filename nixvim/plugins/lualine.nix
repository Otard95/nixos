{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.lualine;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.lualine.enable =
    lib.mkEnableOption "lualine plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.lualine = {
      enable = true;

      settings = {
        options = {
          theme = "catppuccin";
          component_separators = "|";
          section_separators = { left = ""; right = ""; };
        };
        sections = {
          lualine_a = [
            "mode" { separator = { left = ""; }; right_padding = 2; }
          ];
          lualine_b = [ "filename" "branch" ];
          lualine_c = [ "fileformat" ];
          lualine_x = [ "rest" ];
          lualine_y = [ "filetype" "progress" ];
          lualine_z = [
            "location" { separator = { right = ""; }; left_padding = 2; }
          ];
        };
        inactive_sections = {
          lualine_a = [ "filename" ];
          lualine_b = [];
          lualine_c = [];
          lualine_x = [];
          lualine_y = [];
          lualine_z = [ "location" ];
        };
      };
    };
  };
}
