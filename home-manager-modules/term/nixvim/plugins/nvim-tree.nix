{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.nvim-tree;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.nvim-tree.enable =
    lib.mkEnableOption "nvim-tree plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      keymaps = [{
        mode = "n";
        key = "<leader>\\";
        action = nixvim.mkRaw ''require('nvim-tree.api').tree.toggle'';
        options = { silent = true; noremap = true; };
      }];

      colorschemes.catppuccin.settings.integrations.nvimtree = true;
      plugins.nvim-tree = {
        enable = true;
        disableNetrw = true;

        view.width = 40;
        updateFocusedFile = {
          enable = true;
          updateRoot = true;
        };
        git = {
          enable = true;
          ignore = false;
        };
        actions.changeDir = {
          enable = false;
          restrictAboveCwd = true;
        };
        onAttach = nixvim.mkRaw ''
          function(bufnr)
            local api = require 'nvim-tree.api'

            -- Setup default mappings
            api.config.mappings.default_on_attach(bufnr)

            vim.keymap.set('n', 'l', api.node.open.edit, { buffer = bufnr })
            vim.keymap.set('n', 'h', function()
              local node = api.tree.get_node_under_cursor()

              if not node then
                return
              end

              if node.type ~= 'directory' then
                -- If the node is not a directory, navigate to the parent
                api.node.navigate.parent()
              elseif node.open then
                -- If the directory is open, collapse it
                api.node.open.edit() -- collapse the node
              else
                -- If the directory is closed, navigate to the parent
                api.node.navigate.parent()
              end
            end, { buffer = bufnr })
          end
        '';
      };
    };
  };
}
