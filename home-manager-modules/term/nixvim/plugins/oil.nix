{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.oil;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.oil.enable =
    lib.mkEnableOption "oil plugin";

  config = lib.mkIf enable {
    programs.nixvim.keymaps = [{
      mode = "n";
      key = "-";
      action = "<cmd>Oil<cr>";
      options = { silent = true; noremap = true; };
    }];

    programs.nixvim.plugins.oil = {
      enable = true;

      settings = {
        columns = [
          "icon"
          "size"
        ];
        keymaps = {
          "<C-c>" = false;
          "<C-h>" = false;
          "<C-l>" = false;
          "<C-s>" = false;
          "<C-t>" = false;
          "<leader>sh" = "actions.select_split";
          "<leader>sv" = "actions.select_vsplit";
          "<leader>st" = "actions.select_tab";
          "<C-r>" = "actions.refresh";
          "<leader>qq" = "actions.close";
          "y." = "actions.copy_entry_path";
        };
        skip_confirm_for_simple_edits = true;
        view_options = {
          show_hidden = true;
        };
      };
    };
  };
}
