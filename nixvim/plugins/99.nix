{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins._99;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins._99.enable =
    lib.mkEnableOption "_99";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPlugins = with pkgs; [(vimUtils.buildVimPlugin {
        name = "99";
        src = fetchFromGitHub {
          owner = "ThePrimeagen";
          repo = "99";
          rev = "91ea4cfd4a46d756152e9470abe495f4b178e818";
          hash = "sha256-0ezflDXCIcPI/zordlNX5jwwnX2+507kVicif227IUs=";
        };
      })];

      extraConfigLua = ''
        local _99 = require("99")

        -- For logging that is to a file if you wish to trace through requests
        -- for reporting bugs, i would not rely on this, but instead the provided
        -- logging mechanisms within 99.  This is for more debugging purposes
        local cwd = vim.uv.cwd()
        local basename = vim.fs.basename(cwd)
        _99.setup({
          logger = {
            level = _99.DEBUG,
            path = "/tmp/" .. basename .. ".99.debug",
            print_on_error = true,
          },

          --- WARNING: if you change cwd then this is likely broken
          --- ill likely fix this in a later change
          ---
          --- md_files is a list of files to look for and auto add based on the location
          --- of the originating request.  That means if you are at /foo/bar/baz.lua
          --- the system will automagically look for:
          --- /foo/bar/AGENT.md
          --- /foo/AGENT.md
          --- assuming that /foo is project root (based on cwd)
          md_files = {
            "AGENT.md",
          },
        })

        -- Create your own short cuts for the different types of actions
        vim.keymap.set("n", "<leader>9f", function()
          _99.fill_in_function()
        end)
        -- take extra note that i have visual selection only in v mode
        -- technically whatever your last visual selection is, will be used
        -- so i have this set to visual mode so i dont screw up and use an
        -- old visual selection
        --
        -- likely ill add a mode check and assert on required visual mode
        -- so just prepare for it now
        vim.keymap.set("v", "<leader>9v", function()
          _99.visual_prompt()
        end)

        --- if you have a request you dont want to make any changes, just cancel it
        vim.keymap.set("v", "<leader>9s", function()
          _99.stop_all_requests()
        end)
      '';
    };
  };
}
