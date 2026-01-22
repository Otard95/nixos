{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.ai;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.ai.enable =
    lib.mkEnableOption "ai";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPackages = [ pkgs.lsof ];
      extraPlugins = [ pkgs.vimPlugins.opencode-nvim ];
      opts.autoread = true;
      globals.opencode_opts = {
        provider = {
          enabled = "${config.modules.term.defaultTerminal}";
          wezterm = { };
        };
      };
      keymaps = [
        {
          mode = [ "n" "x" ];
          key = "<leader>oat";
          action = nixvim.mkRaw "function() require('opencode').ask('@this: ', { submit = true }) end";
          options = { desc = "Ask opencode"; };
        }
        {
          mode = "n";
          key = "<leader>oab";
          action = nixvim.mkRaw "function() require('opencode').ask('@buffer: ', { submit = true }) end";
          options = { desc = "Ask opencode"; };
        }
        {
          mode = [ "n" "x" ];
          key = "<leader>os";
          action = nixvim.mkRaw "function() require('opencode').select() end";
          options = { desc = "Execute opencode action…"; };
        }
        {
          mode = [ "n" "t" ];
          key = "<leader>ot";
          action = nixvim.mkRaw "function() require('opencode').toggle() end";
          options = { desc = "Toggle opencode"; };
        }

        {
          mode = [ "n" "x" ];
          key = "<leader>ogo";
          action = nixvim.mkRaw "function() return require('opencode').operator('@this ') end";
          options = { expr = true; desc = "Add range to opencode"; };
        }
        {
          mode = "n";
          key = "<leader>ogoo";
          action = nixvim.mkRaw "function() return require('opencode').operator('@this ') .. '_' end";
          options = { expr = true; desc = "Add line to opencode"; };
        }

        {
          mode = "n";
          key = "<S-C-u>";
          action = nixvim.mkRaw "function() require('opencode').command('session.half.page.up') end";
          options = { desc = "opencode half page up"; };
        }
        {
          mode = "n";
          key = "<S-C-d>";
          action = nixvim.mkRaw "function() require('opencode').command('session.half.page.down') end";
          options = { desc = "opencode half page down"; };
        }

        # Not sure how to translate this
        # vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
        # vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
      ];

      plugins = {
        snacks = {
          enable = true;

          settings = { input.enabled = true; picker.enabled = true; terminal.enabled = true; };
        };

        # minuet = {
        #   enable = true;

        #   settings = {
        #     provider = "openai_fim_compatible";
        #     n_completions = 1; # recommend for local model for resource saving
        #     # I recommend beginning with a small context window size and incrementally
        #     # expanding it; depending on your local computing power. A context window
        #     # of 512; serves as an good starting point to estimate your computing
        #     # power. Once you have a reliable estimate of your local computing power;
        #     # you should adjust the context window to a larger value.
        #     context_window = 512; # original: 512
        #     debounce = 100; # original: 400

        #     provider_options = {
        #       openai_fim_compatible = {
        #         # For Windows users; TERM may not be present in environment variables.
        #         # Consider using APPDATA instead.
        #         api_key = "TERM";
        #         name = "Ollama";
        #         end_point = "http://localhost:11434/v1/completions";
        #         model = "qwen2.5-coder:latest";
        #         optional = {
        #           max_tokens = 56;
        #           top_p = 0.9;
        #         };
        #       };
        #     };

        #     virtualtext = {
        #       auto_trigger_ft = ["*"];
        #       auto_trigger_ignore_ft = ["markdown"];
        #       keymap = {
        #         # accept whole completion
        #         accept = "<A-A>";
        #         # accept one line
        #         accept_line = "<A-a>";
        #         # accept n lines (prompts for number)
        #         # e.g. "A-z 2 CR" will accept 2 lines
        #         accept_n_lines = "<A-z>";
        #         # Cycle to prev completion item; or manually invoke completion
        #         prev = "<A-[>";
        #         # Cycle to next completion item; or manually invoke completion
        #         next = "<A-]>";
        #         dismiss = "<A-e>";
        #       };
        #     };
        #   };
        # };
      };
    };
  };
}
