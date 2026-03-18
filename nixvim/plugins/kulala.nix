{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.kulala;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.kulala.enable =
    lib.mkEnableOption "kulala plugin";

  config = lib.mkIf enable {

    programs.nixvim = {

      extraPackages = [ pkgs.prettier ];

      plugins.kulala = {
        enable = true;

        package = pkgs.vimUtils.buildVimPlugin {
          name = "kulala.nvim";
          src = pkgs.fetchFromGitHub {
            owner = "mistweaverco";
            repo = "kulala.nvim";
            rev = "5fe5c671b7c579fdc0556d4bf3e117a1c3229393";
            hash = "sha256-BZjGh+8V1vALotrLVM2aiCESZghAvfE2/Yjqhpc75x8=";
            fetchSubmodules = true;
          };
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
