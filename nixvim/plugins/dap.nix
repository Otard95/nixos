{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.dap;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.dap.enable =
    lib.mkEnableOption "dap plugin";

  config = lib.mkIf enable {
    programs.nixvim = {

      keymaps = map (m: {
        mode = builtins.elemAt m 0;
        key = builtins.elemAt m 1;
        action = builtins.elemAt m 2;
        options = { silent = true; } // builtins.elemAt m 3;
      }) [
        [ "n" "<leader>db" (nixvim.mkRaw ''require("dap").toggle_breakpoint'') {} ]
        [ "n" "<leader>dcb" (nixvim.mkRaw ''
          function ()
            -- Get user input
            local input = vim.fn.input('Condition: ')
            if not input or input == "" then return end

            require('dap').set_breakpoint(input)
          end
        '' ) {} ]
        [ "n" "<leader>dr" (nixvim.mkRaw ''require("dap").continue'') {} ]
        [ "n" "<leader>dq" (nixvim.mkRaw ''require("dap").terminate'') {} ]
        [ "n" "<leader>dn" (nixvim.mkRaw ''require("dap").step_over'') {} ]
        [ "n" "<leader>di" (nixvim.mkRaw ''require("dap").step_into'') {} ]
        [ "n" "<leader>du" (nixvim.mkRaw ''require("dap").step_out'') {} ]
        [ "n" "<leader>dl" (nixvim.mkRaw ''require("dap").run_to_cursor'') {} ]
        [ "n" "<leader>dk" (nixvim.mkRaw ''require("dap.ui.widgets").hover'') {} ]
      ];

      extraConfigLua = ''
        require('dap').listeners.after.event_initialized['dapui_config'] = function()
          require('dapui').open()
        end
        require('dap').listeners.before.event_terminated['dapui_config'] = function()
          require('dapui').close()
        end
        require('dap').listeners.after.disconnect['dapui_config'] = function()
          require('dapui').close()
        end
        require('dap').listeners.before.event_exited['dapui_config'] = function()
          require('dapui').close()
        end
      '';

      plugins.dap = {
        enable = true;

        extensions = {
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
        };

        signs = {
          dapBreakpoint = {
            text="⬤";
            texthl="DapBreakpoint";
            linehl="DapBreakpoint";
            numhl="DapBreakpoint";
          };
          dapBreakpointCondition = {
            text="";
            texthl="DapBreakpoint";
            linehl="DapBreakpoint";
            numhl="DapBreakpoint";
          };
          dapBreakpointRejected = {
            text="";
            texthl="DapBreakpointRejected";
            linehl="DapBreakpointRejected";
            numhl="DapBreakpointRejected";
          };
          dapLogPoint = {
            text="";
            texthl="DapLogPoint";
            linehl="DapLogPoint";
            numhl="DapLogPoint";
          };
          dapStopped = {
            text="";
            texthl="DapStopped";
            linehl="DapStopped";
            numhl="DapStopped";
          };
        };

        adapters = {
          servers = {
            pwa-node = {
              host = "::1";
              port = 8123;
              executable = {
                command = "${pkgs.vscode-js-debug}/bin/js-debug";
                args = [ "8123" ];
                # cwd = vim.fn.getcwd();
              };
              options = {
                maxRetries = 40;
              };
            };
          };

          executables = {
            php = {
              command = "php-debug-adapter";
              # TODO: Test this
              # enrich_config = nixvim.mkRaw ''
              #   function(conf, on_config)
              #     if not conf.localSourceRoot then
              #       local config = vim.deepcopy(conf)
              #       config.pathMappings = {
              #         ["/var/www/html/"] = vim.fn.getcwd().."/",
              #       }
              #       on_config(config)
              #     else
              #       on_config(conf)
              #     end
              #   end
              # '';
            };
          };
        };
      };
    };
  };
}
