{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.kulala;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.kulala.enable =
    lib.mkEnableOption "kulala plugin";

  config = let
    kulala_src = pkgs.fetchFromGitHub {
      owner = "mistweaverco";
      repo = "kulala.nvim";
      rev = "5fe5c671b7c579fdc0556d4bf3e117a1c3229393";
      hash = "sha256-BZjGh+8V1vALotrLVM2aiCESZghAvfE2/Yjqhpc75x8=";
      fetchSubmodules = true;
    };

    treesitter-kulala-http-grammar = pkgs.tree-sitter.buildGrammar {
      language = "kulala_http";
      version = "5.3.1";
      src = kulala_src;
      location = "lua/tree-sitter";
    };
  in lib.mkIf enable {

    programs.nixvim = {

      extraPackages = [ pkgs.prettier ];

      plugins.treesitter.grammarPackages = [ treesitter-kulala-http-grammar ];

      plugins.kulala = {
        enable = true;

        package = pkgs.vimUtils.buildVimPlugin {
          name = "kulala.nvim";
          src = kulala_src;
          nvimSkipModule = [ "cli.kulala_cli" ];
        };

        settings = {
          environment_scope = "g";
          split_direction = "horizontal";
          global_keymaps = true;
          global_keymaps_prefix = "<leader>r";
          additional_curl_options = [
            "--cookie" (nixvim.mkRaw "require('kulala.globals').COOKIES_JAR_FILE")
          ];
        };
      };

    };

  };
}
