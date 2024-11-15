{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.text-manipulation;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.text-manipulation.enable =
    lib.mkEnableOption "text-manipulation plugins";

  config = lib.mkIf enable {
    programs.nixvim.keymaps = [
      { # Start multicursor from normal mode
        mode = "n";
        key = "<leader>m";
        action = "<cmd>MCstart<cr>";
        options = { silent = true; };
      }
      { # Start multicursor from visual mode
        mode = "v";
        key = "<leader>m";
        action = "<cmd>MCstart<cr>";
        options = { silent = true; };
      }
    ];

    programs.nixvim.plugins = {
      commentary.enable = true;
      vim-surround.enable = true;
      multicursors.enable = true;
      #TODO: nvim-align or checkout mini
      #TODO: vim-abolish
    };
  };
}
