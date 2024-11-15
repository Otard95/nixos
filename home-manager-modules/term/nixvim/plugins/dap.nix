{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.dap;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.dap.enable =
    lib.mkEnableOption "dap plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.dap = {
      enable = true;

      extensions = {
        dap-ui.enable = true;
        dap-virtual-text.enable = true;
      };

      # TODO: Adapters and configurations
    };
  };
}
