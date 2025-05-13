{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.neotest;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.neotest.enable =
    lib.mkEnableOption "neotest";

  config = lib.mkIf enable {

    programs.nixvim = {
      keymaps = [
        {
          mode = "n";
          key = "<leader>tt";
          action = nixvim.mkRaw ''require("neotest").run.run'';
          options = { silent = true; noremap = true; };
        }
        {
          mode = "n";
          key = "<leader>tf";
          action = nixvim.mkRaw ''function() require("neotest").run.run(vim.fn.expand("%")) end'';
          options = { silent = true; noremap = true; };
        }
        {
          mode = "n";
          key = "<leader>td";
          action = nixvim.mkRaw ''function() require("neotest").run.run({strategy = "dap"}) end'';
          options = { silent = true; noremap = true; };
        }
        {
          mode = "n";
          key = "<leader>ts";
          action = nixvim.mkRaw ''require("neotest").summary.toggle'';
          options = { silent = true; noremap = true; };
        }
        {
          mode = "n";
          key = "<leader>to";
          action = nixvim.mkRaw ''require("neotest").output_panel.toggle'';
          options = { silent = true; noremap = true; };
        }
      ];

      plugins.neotest = {
        enable = true;

        adapters.jest = {
          enable = true;
          settings = {
            cwd = nixvim.mkRaw ''
              function(file) return vim.fs.root(file, "jest.config.js") end
            '';
            filter_dir = nixvim.mkRaw ''
              function(name, rel_path, root)
                return name ~= "node_modules"
              end
            '';
          };
        };
      };
    };

  };
}
