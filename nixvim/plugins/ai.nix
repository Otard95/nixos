{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.ai;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.ai.enable =
    lib.mkEnableOption "ai";

  config = lib.mkIf enable {
    programs.nixvim.plugins = {
      codecompanion = {
        enable = true;

        settings = {
          adapters = {
            ollama = nixvim.mkRaw ''
              function()
                return require('codecompanion.adapters').extend('ollama', {
                  schema = {
                    model = {
                      default = 'qwen2.5-coder:latest', -- context: 32768
                      -- default = 'qwen3:latest', -- context: 40960
                      -- default = 'deepseek-r1:latest', -- context: 131072
                      -- default = "llama3.1:8b-instruct-q8_0",
                    },
                    num_ctx = {
                      default = 32768,
                    },
                  },
                })
              end
            '';
          };
          strategies = {
            agent = {
              adapter = "ollama";
            };
            chat = {
              adapter = "ollama";
            };
            inline = {
              adapter = "ollama";
            };
          };
        };
      };
      avante = {
        enable = false;

        settings = {
          provider = "ollama";
          providers = {
            ollama = {
              endpoint = "http://localhost:11434";
              model = "qwen2.5-coder:latest";
            };
          };
        };
      };
      render-markdown.settings.file_types = [ "markdown" "codecompanion" ];

      minuet = {
        enable = true;

        settings = {
          provider = "openai_fim_compatible";
          n_completions = 1; # recommend for local model for resource saving
          # I recommend beginning with a small context window size and incrementally
          # expanding it; depending on your local computing power. A context window
          # of 512; serves as an good starting point to estimate your computing
          # power. Once you have a reliable estimate of your local computing power;
          # you should adjust the context window to a larger value.
          context_window = 1024; # original: 512
          provider_options = {
            openai_fim_compatible = {
              # For Windows users; TERM may not be present in environment variables.
              # Consider using APPDATA instead.
              api_key = "TERM";
              name = "Ollama";
              end_point = "http://localhost:11434/v1/completions";
              model = "qwen2.5-coder:latest";
              optional = {
                max_tokens = 56;
                top_p = 0.9;
              };
            };
          };

          virtualtext = {
            auto_trigger_ft = ["*"];
            auto_trigger_ignore_ft = ["markdown"];
            keymap = {
              # accept whole completion
              accept = "<A-A>";
              # accept one line
              accept_line = "<A-a>";
              # accept n lines (prompts for number)
              # e.g. "A-z 2 CR" will accept 2 lines
              accept_n_lines = "<A-z>";
              # Cycle to prev completion item; or manually invoke completion
              prev = "<A-[>";
              # Cycle to next completion item; or manually invoke completion
              next = "<A-]>";
              dismiss = "<A-e>";
            };
          };
        };
      };

    };
  };
}
