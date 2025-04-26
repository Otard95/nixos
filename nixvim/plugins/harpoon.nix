{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.harpoon;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.harpoon.enable =
    lib.mkEnableOption "harpoon plugin";

  config = lib.mkIf enable {

    programs.nixvim = {

      plugins.harpoon = {
        enable = true;
        enableTelescope = true;
      };

      keymaps = [
        { mode = "n"; key = "<leader>a";
          action.__raw = "function() require'harpoon':list():add() end"; }
        { mode = "n"; key = "<leader>e";
          action.__raw = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end"; }
        { mode = "n"; key = "<leader>h";
          action.__raw = "function() require'harpoon':list():select(1) end"; }
        { mode = "n"; key = "<leader>j";
          action.__raw = "function() require'harpoon':list():select(2) end"; }
        { mode = "n"; key = "<leader>k";
          action.__raw = "function() require'harpoon':list():select(3) end"; }
        { mode = "n"; key = "<leader>l";
          action.__raw = "function() require'harpoon':list():select(4) end"; }
        { mode = "n"; key = "<leader>;";
          action.__raw = "function() require'harpoon':list():select(5) end"; }
        { mode = "n"; key = "<leader>'";
          action.__raw = "function() require'harpoon':list():select(6) end"; }
     ];

    };

  };
}
