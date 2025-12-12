{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.rest;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.rest.enable =
    lib.mkEnableOption "rest plugin";

  config = lib.mkIf enable {

    programs.nixvim = {

      extraPackages = with pkgs; [ jq ];

      autoCmd = [
        {
          event = "FileType";
          pattern = [ "http" "rest" ];
          callback = nixvim.mkRaw ''
            function(ev)
              vim.opt_local.splitright = true

              local opts = { buffer = ev.buf }
              vim.keymap.set({ 'n' }, '<leader>rr', '<cmd>hor bo Rest run<CR>', opts)
              vim.keymap.set({ 'n' }, '<leader>rl', '<cmd>hor bo Rest run last<CR>', opts)
              vim.keymap.set({ 'n' }, '<leader>re', require('telescope').extensions.rest.select_env, opts)
            end
          '';
        }
        {
          event = "FileType";
          pattern = [ "json" ];
          callback = nixvim.mkRaw ''
            function(ev) vim.bo.formatprg = "${pkgs.writeShellScriptBin "format" ''
              input=$(cat)

              # Try to format it with jq
              if formatted=$(printf '%s\n' "$input" | jq '.'); then
                # jq succeeded: output formatted JSON
                printf '%s\n' "$formatted"
              else
                # jq failed: output original text
                printf '%s\n' "$input" | ${pkgs.lynx}/bin/lynx -stdin -dump
              fi
            ''}/bin/format" end
          '';
        }
      ];

      plugins.rest = {
        enable = true;
        enableTelescope = true;

        settings = {
          request.hooks.encode_url = false;
        };
      };

    };

  };
}
