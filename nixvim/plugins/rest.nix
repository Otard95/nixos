{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.rest;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.rest.enable =
    lib.mkEnableOption "rest plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      autoCmd = [
        {
          event = "FileType";
          pattern = [ "http" "rest" ];
          callback = nixvim.mkRaw ''
            function(ev)
              vim.opt_local.splitright = true

              local opts = { buffer = ev.buf }
              vim.keymap.set({ 'n' }, '<leader>rr', '<cmd>Rest run<CR>', opts)
              vim.keymap.set({ 'n' }, '<leader>rl', '<cmd>Rest run last<CR>', opts)
              vim.keymap.set({ 'n' }, '<leader>re', require('telescope').extensions.rest.select_env, opts)
            end
          '';
        }
      ];

      plugins.rest = {
        enable = true;
        enableTelescope = true;
      };
    };
  };
}
